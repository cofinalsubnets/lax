$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'rake'
require 'lax/version'

Gem::Specification.new do |spec|
  spec.name        = 'lax'
  spec.version     = Lax::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['lax.gemspec','lib/**/*','README.md','LICENSE']
  spec.test_files  = FileList['test/**/*.rb','spec/**/*.rb']
  spec.license     = 'MIT/X11'
  spec.homepage    = 'http://github.com/gwentacle/lax'
  spec.summary     = 'An insouciant smidgen of a testing framework.'
  spec.description = 'A lightweight testing framework.'
  spec.add_development_dependency 'rspec'
end
