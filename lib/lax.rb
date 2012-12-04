require 'lax/version'
module Lax
  autoload :Tree,   'lax/tree'
  autoload :Task,   'lax/task'
  autoload :Runner, 'lax/runner'
  autoload :Hook,   'lax/hook'
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

