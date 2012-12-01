require 'stilts/version'
module Stilts
  autoload :Group,    'stilts/group'
  autoload :RakeTask, 'stilts/rake_task'
  autoload :Runner,   'stilts/runner'
  class << self
    @@queue = []
    def group(c={})
      c = {obj: c} unless Hash===c
      yield(group = Group.new(c))
      @@queue += group.cases
    end

    def go!(runner_opts={})
      Runner.new(@@queue, runner_opts).go
    end
  end
end

