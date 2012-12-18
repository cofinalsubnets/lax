require 'rake'
module Lax
  module Task
    class << self
      include Rake::DSL
      def new(opts = {})
        opts = Lax.defaults :task, opts
        namespace :lax do
          task(:load) { Dir["#{opts[:dir]}/**/*.rb"].each {|f| load f} }
          task(:run)  { Lax::Runner.new.go }
        end
        task lax: %w{lax:load lax:run}
      end
    end
  end
end

