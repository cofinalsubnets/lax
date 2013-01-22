require 'rspec'
require 'lax'
require 'pry'
require_relative 'support/matchers'

RSpec.configure do |config|
  config.color_enabled = true
#  config.formatter = :documentation
  config.after :each do
    Lax::TESTS.clear
  end
end


