require 'rake'
require 'lax'
require 'lax/output'
class Lax
  module RakeTask
    class << self
      include Rake::DSL
      def new(opts = {})
        o = {dir: :test, name: :lax}.merge(opts)
        namespace o[:name] do
          task(:load) { Dir["./#{o[:dir]}/**/*.rb"].each {|f| load f} }
          task(:run) do
            Lax.after &Output::DOTS
            Run[ Lax ].tap {|v| binding.pry}
          end
        end
        task o[:name] => ["#{o[:name]}:load", "#{o[:name]}:run"]
      end
    end
  end
end

