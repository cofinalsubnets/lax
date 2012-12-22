require 'rspec'
require 'lax'
require 'pry'

RSpec.configure do |config|
  config.color_enabled = true
end

Lax.config.assertion.hooks.after = Lax::Hook.noop

