require 'rspec'
require 'lax'
require 'pry'

RSpec.configure do |config|
  config.color_enabled = true
end

Lax.config.run.hooks.after = Lax::Hook.noop # suppress output

