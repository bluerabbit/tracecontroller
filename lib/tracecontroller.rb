class Tracecontroller
  VERSION = Gem.loaded_specs['tracecontroller'].version.to_s
  attr_reader :errors

  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), "tasks/tracecontroller.rake")
    end
  end

  def initialize(app)
    @app = app
  end

  def valid?
    if @errors
      return @errors[:callback].blank? && @errors[:superclass].blank?
    end

    @app.eager_load!
    @app.reload_routes!

    routes = collect_routes(Rails.application.routes.routes).reject {|r| r.requirements[:controller].to_s.blank? }

    @errors = controllers(routes).each.with_object({callback: [], superclass: []}) do |row, errors|
      rules.each do |rule|
        if !rule[:path].match?(row[:path]) || rule[:ignore_classes].any? {|r| r.match? row[:controller_name] }
          next
        end

        if rule[:superclass].present? && row[:superclass_name] != rule[:superclass]
          errors[:superclass] << row[:controller_name]
        end

        callbacks = rule[:require_actions] - row[:callbacks]

        if callbacks.present?
          errors[:callback] << {controller_name: row[:controller_name], callbacks: callbacks}
        end
      end
    end

    @errors[:callback].blank? && @errors[:superclass].blank?
  end

  private

  def config_filename
    %w[.tracecontroller.yaml .tracecontroller.yml].detect { |f| File.exist?(f) }
  end

  def rules
    @rules ||= (config_filename ? YAML.load_file(config_filename) : []).map do |rule|
      require_actions = (rule["actions"] || []).each.with_object([]) do |h, array|
        h.each do |key, filters|
          filters.each do |filter|
            array << { kind: key.to_sym, filter: filter.to_sym }
          end
        end
      end

      {
        path:            Regexp.new(rule["path"]),
        require_actions: require_actions,
        superclass:      rule["superclass"],
        ignore_classes:  (rule["ignore_classes"] || []).map {|c| Regexp.new(c) },
      }
    end
  end

  def controllers(routes)
    routes.sort_by {|r| r.path.spec.to_s }.each.with_object([]) do |route, array|
      controller_name = "#{route.requirements[:controller].camelize}Controller"

      next if array.any? {|c| c[:controller_name] == controller_name }

      begin
        controller = controller_name.constantize
      rescue NameError => e
        puts "#{e.message} path:#{route.path.spec}"
        next
      end

      array << {
        controller_name: controller.name,
        superclass_name: controller.superclass.name,
        callbacks:       controller.__callbacks[:process_action].map {|c| { kind: c.kind, filter: c.filter } },
        path:            route.path.spec.to_s,
      }
    end
  end

  def collect_routes(routes)
    routes = routes.each_with_object([]) do |r, tmp_routes|
      next if r.app.is_a?(ActionDispatch::Routing::Mapper::Constraints) && %w[ActionDispatch::Routing::PathRedirect ActionDispatch::Routing::Redirect].include?(r.app.app.class.name)

      if r.app.is_a?(ActionDispatch::Routing::Mapper::Constraints) && r.app.app.respond_to?(:routes)
        engine_routes = r.app.app.routes
        if engine_routes.is_a?(ActionDispatch::Routing::RouteSet)
          tmp_routes.concat collect_routes(engine_routes.routes)
        end
      else
        tmp_routes << r
      end
    end

    routes.reject! {|r| r.app.is_a?(ActionDispatch::Routing::Redirect) }
    routes
  end
end
