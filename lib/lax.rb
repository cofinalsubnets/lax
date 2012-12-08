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
      Tree.new(c).tap(&b).leaves.tap{|cs|@@cases+=cs}
    end

    def go(opts={})
      Runner.new(opts.delete(:cases) || @@cases, opts).go
    end
  end
end

