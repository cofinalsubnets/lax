require 'lax/version'
module Lax
  autoload :Case,   'lax/case'
  autoload :Tree,   'lax/tree'
  autoload :Runner, 'lax/runner'
  autoload :Hook,   'lax/hook'
  autoload :Task,   'lax/task'

  class << self
    @@cases = []
    def test(c={},&b)
      @@cases += Tree.new(c).tap(&b).leaves
    end

    def go(runner_opts={})
      Runner.new(@@cases, runner_opts).go
    end
  end
end

