require 'rake'
module Lax
  # Helper for running Lax as a Rake task.
  module RakeTask
    class << self
      include Rake::DSL
      # Creates and returns a new Rake task (called 'lax') for running Lax.
      # Takes an optional hash of parameters; at present the only recognized
      # parameter is :dir, which names the directory relative to the Rakefile
      # containing the files for Lax to load (defaults to 'test' - this can
      # also be configured through Lax.config).
      def new(opts = {})
        opts = Lax.defaults :task, opts
        namespace :lax do
          task(:load) { Dir["./#{opts[:dir]}/**/*.rb"].each {|f| load f} }
          task(:run) do
            Lax.config.runner.threads > 0 ?
              Lax::Runner.new.run.finish :
              Lax::Runner.new.run
          end
        end
        task lax: %w{lax:load lax:run}
      end
    end
  end
end

