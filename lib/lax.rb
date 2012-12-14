require 'lax/version'
module Lax
  autoload :Tree, 'lax/tree'
  autoload :Hook, 'lax/hook'
  autoload :Task, 'lax/task'

  class << self; attr_accessor :cases end
  self.cases = []

  def self.test(c={},&b)
    Tree.new.where(c,&b).leaves.tap {|cs|self.cases+=cs}
  end

  def self.test!(cases=self.cases, opts={})
    call opts[:start], cases
    cases.each do |c|
      call opts[:before], c
      test_case c
      call opts[:after], c
    end
    call opts[:finish], cases
    cases
  end

  def self.test_case(tc)
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

  private
  def self.call(p, *as)
    p[*as] if p
  end
end

