$:.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name        = 'tracecontroller'
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Akira Kusumoto']
  s.email       = ['akirakusumo10@gmail.com']
  s.homepage    = 'https://github.com/bluerabbit/tracecontroller'
  s.summary     = 'A Rake task that helps you find the missing callbacks for your Rails app'
  s.description = "This Rake task investigates the application's controller, then tells you missing callbacks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.add_dependency 'rails', ['>= 5.0.0']
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec', '~> 3.9'
end
