require 'rake'
class Lax
  module RakeTask
    extend Rake::DSL
    DEFAULTS = {
      name: :lax,
      dir: :test,
    }
    def self.new(opts={})
      opts = DEFAULTS.merge(opts)
      task opts[:name] do
        Lax::Configuration::BASIC_OUTPUT.apply
        Lax.load Dir["./#{opts[:dir]}/**/*.rb"]
        Lax.run
      end
    end
  end
end

