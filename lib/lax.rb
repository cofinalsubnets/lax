require 'lax/version'
module Lax
  autoload :Tree, 'lax/tree'
  autoload :Hook, 'lax/hook'
  autoload :Task, 'lax/task'

  class << self
    @@cases = []
    def test(c={},&b)
      preproc(b)[t=Tree.new(c)]
      t.leaves.tap {|cs|@@cases+=cs}
    end

    def test!(opts={})
      cases = opts[:cases] || @@cases
      call opts[:start], cases
      cases.each do |c|
        call opts[:before], c
        test_case c
        call opts[:after], c
      end
      call opts[:finish], cases
      cases
    end

    def call(p, *as)
      p[*as] if p
    end

    def preproc(p)
      p.parameters.any?? p : ->(o) { o.instance_exec &p }
    end

    def test_case(tc)
      call tc[:before], tc
      tc[:pass] = begin
        tc[:cond][tc[:value]=tc[:obj].__send__(tc[:msg],*tc[:args],&tc[:blk])]
      rescue tc[:xptn] => e
        true
      rescue => e
        tc[:xptn] = e
        false
      end
      call tc[:after], tc
    end
  end
end

