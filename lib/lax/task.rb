require 'rake'
module Lax
  module Task
    class << self
      include Rake::DSL
      def new(opts = {})
        dir = opts.delete(:dir) || :test
        make_tasks dir, opts
      end

      private
      def make_tasks(dir, opts)
        namespace :lax do
          desc "load test files"
          task(:load) {Dir["#{dir}/**/*.rb"].each {|f| load f}}
          desc "run all loaded tests"
          task(:run) { Lax.test_all opts }
        end
        desc "load and run all tests"
        task lax: %w{lax:load lax:run}
      end
    end
  end
end

