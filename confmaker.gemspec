Gem::Specification.new do |s|
  s.name        = 'confmaker'
  s.version     = '0.0.1'
  s.summary     = "Your utility configuration maker"
  s.description = "Configuration getter, parser and validator"
  s.authors     = ["nothing"]
  s.files       = ["lib/confmaker.rb","lib/confsources.rb","lib/confoptions.rb"]
  s.add_runtime_dependency 'thor'
end
