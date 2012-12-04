require 'lax/version'
module Lax
  autoload :Case,   'lax/case'
  autoload :Tree,   'lax/tree'
  autoload :Task,   'lax/task'
  autoload :Runner, 'lax/runner'
  autoload :Hook,   'lax/hook'
  class << self
    @@cases = []
    def test(c={},&b)
      @@cases += Tree.new(Case.new.merge c).tap(&b).leaves
    end

    def go(runner_opts={})
      Runner.new(@@cases, runner_opts).go
    end
  end
end

