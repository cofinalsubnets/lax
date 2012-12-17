require 'rake'
module Lax
  module Task
    class << self
      include Rake::DSL
      def new(opts = {})
        dir  = opts.delete(:dir) || :test
        make_task dir, {after: Hook.pass_fail}.merge(opts)
      end
      private
      def make_task(dir, opts)
        task :lax do
          Dir["#{dir}/**/*.rb"].each {|f| load f}
          results = []
          multitask(run: Lax::Group::USER.map {|g| task {results << g.test(opts)}}).invoke
          (Hook.summary+Hook.failures)[results.flatten]
        end
      end
    end
  end
end

