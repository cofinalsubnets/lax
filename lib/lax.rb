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

    def test!(opts={})
      cases = opts[:cases] || @@cases
      call opts[:start], cases
      done = cases.map do |c|
        call opts[:before], c
        c.test
        call opts[:after], c
        c
      end
      call opts[:finish], done
      done
    end

    private
    def call(p, *as)
      p[*as] if Proc===p
    end
  end
end

