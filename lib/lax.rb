require 'lax/version'
module Lax
  autoload :Tree,     'lax/tree'
  autoload :RakeTask, 'lax/rake_task'
  autoload :Runner,   'lax/runner'
  autoload :CB,       'lax/cb'
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

