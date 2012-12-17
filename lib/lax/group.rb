module Lax
  class Group
    autoload :Node, 'lax/group/node'
    autoload :Case, 'lax/group/case'
    USER = []
    def self.test(hooks={}); new(hooks).test end
    def self.define(hooks, spec)
      group = Class.new(self)
      group.const_set :HOOKS, hooks
      group.const_set :SPEC,  spec
      (USER << group).last
    end

    attr_reader :cases, :hooks
    def initialize(hooks={})
      @hooks = self.class::HOOKS.merge(hooks)
      @cases = Node.new.tap{|n|n._ n,&self.class::SPEC}.cases
    end

    def test
      around(cases, :start, :finish) {cases.map {|c| around(c) {c.test}}}
    end

    private
    def around(init=nil, h1=:before, h2=:after)
      run_hook h1, init
      yield.tap{|v|run_hook h2,v}
    end

    def run_hook(h,*a)
      hooks[h][*a] if hooks[h]
    end
  end
end

