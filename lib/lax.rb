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
      t=Tree.new c
      b.parameters.any?? b[t] : t.instance_exec(&b)
      t.leaves.tap {|cs|@@cases+=cs}
    end

    def go(opts={})
      Runner.new(opts.delete(:cases) || @@cases, opts).go
    end
  end
end

