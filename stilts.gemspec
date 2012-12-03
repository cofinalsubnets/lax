$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'rake'
require 'stilts/version'

Gem::Specification.new do |spec|
  spec.name        = 'stilts'
  spec.version     = Stilts::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['stilts.gemspec','lib/**/*.rb']
  spec.test_files  = FileList['rakefile','test/**/*.rb']
  spec.license     = 'MIT/X11'
  spec.homepage    = 'http://github.com/gwentacle/stilts'
  spec.summary     = 'An acceptably wobbly testing framework.'
  spec.description = 'A testing framework that tries to stay out of your way.'
end
