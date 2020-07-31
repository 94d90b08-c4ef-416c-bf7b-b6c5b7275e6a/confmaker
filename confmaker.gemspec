Gem::Specification.new do |s|
  s.name        = 'confmaker'
  s.version     = "1.0.#{`git diff --quiet && git log -n1 --pretty=%h || date +%s`.chomp}"
  s.summary     = 'Configuration maker for your utility '
  s.description = 'Configuration getter, parser and validator'
  s.authors     = ['nothing']
  s.files       = ['lib/confmaker.rb', 'lib/confsources.rb', 'lib/confoptions.rb']
  s.add_runtime_dependency 'thor'
end
