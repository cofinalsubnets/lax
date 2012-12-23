require 'rake'
require 'lax'
class Lax
  module RakeTask
    class << self
      include Rake::DSL
      def new(opts = {})
        o = Lax.config.task.merge opts
        namespace o[:name] do
          task(:load) { Dir["./#{o[:dir]}/**/*.rb"].each {|f| load f} }
          task(:run) do
            Lax.config do |lax|
              lax.run.after  += Hook.output
              lax.run.finish += Hook.failures + Hook.summary
            end
            Run[ Lax ]
          end
        end
        task o[:name] => ["#{o[:name]}:load", "#{o[:name]}:run"]
      end
    end
  end
end

