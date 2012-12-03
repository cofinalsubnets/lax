require 'stilts/version'
module Stilts
  autoload :Tree,     'stilts/tree'
  autoload :RakeTask, 'stilts/rake_task'
  autoload :Runner,   'stilts/runner'
  autoload :CB,       'stilts/cb'
  class << self
    @@cases = []
    def test(c={})
      yield(group = Tree.new(Hash===c ? c : {obj: c}))
      @@cases += group.cases
    end

    def go(runner_opts={})
      Runner.new(@@cases.shift(@@cases.size), runner_opts).go
    end
  end
end

