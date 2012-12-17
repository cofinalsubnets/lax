require 'rake'
module Lax
  module Task
    class << self
      include Rake::DSL
      def new(opts = {})
        opts = Lax.recursive_merge(Lax.config[:task], opts)
        make_task opts
      end
      private
      def make_task(opts)
        task :lax do
          Dir["#{opts[:dir]}/**/*.rb"].each {|f| load f}
          results = []
          multitask(run: Lax::Group::USER.map {|g| task {results << g.new(opts[:group]).test}}).invoke
          opts[:finish][results.flatten] if opts[:finish]
        end
      end
    end
  end
end

