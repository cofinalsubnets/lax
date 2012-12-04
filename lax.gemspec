$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'rake'
require 'stilts/version'

Gem::Specification.new do |spec|
  spec.name        = 'lax'
  spec.version     = Lax::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['lax.gemspec','lib/**/*.rb','README.md','LICENSE']
  spec.test_files  = FileList['rakefile','test/**/*.rb']
  spec.license     = 'MIT/X11'
  spec.homepage    = 'http://github.com/gwentacle/lax'
  spec.summary     = 'A more forgiving testing framework.'
  spec.description = 'A testing framework that tries to stay out of your way.'
end
