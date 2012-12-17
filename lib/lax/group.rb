module Lax
  class Group
    include Hook::Run
    autoload :Node, 'lax/group/node'
    autoload :Case, 'lax/group/case'
    DEFS = []
    def self.define(hooks, spec)
      group = Class.new(self)
      group.const_set :HOOKS, hooks
      group.const_set :SPEC,  spec
      (DEFS << group).last
    end

    attr_reader :cases
    def initialize(hooks={})
      @hooks = self.class::HOOKS.merge(hooks)
      @cases = Node.new.tap{|n|n._ n,&self.class::SPEC}.cases
    end

    def test
      around(cases, :start, :finish) {cases.map {|c| around(c) {c.test}}}
    end
  end
end

