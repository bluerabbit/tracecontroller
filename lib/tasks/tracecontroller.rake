desc 'Prints out missing callbacks'
task tracecontroller: :environment do
  tracecontroller = Tracecontroller.new(Rails.application)
  tracecontroller.valid?

  tracecontroller.errors[:callback].each do |error|
    puts "#{error[:controller_name]} Missing callbacks."

    error[:callback].each do |callback|
      puts "  #{callback[:kind]}_action: #{callback[:filter]}"
    end
  end

  tracecontroller.errors[:superclass].each do |name|
    puts "#{name} Missing superclass."
  end

  if ENV['FAIL_ON_ERROR'] && tracecontroller.valid?
    raise 'Missing callbacks or superclass detected.'
  end
end
