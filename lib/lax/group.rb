module Lax
  class Group
    include Hook::Run
    def self.inherited(klass); Lax.groups << klass end
    def self.test(hooks={});   new(hooks).test     end
    def self.define(hooks, treespec)
      Class.new(self).tap do |klass|
        klass.const_set :HOOKS, hooks
        klass.const_set :TREESPEC, treespec
      end
    end

    attr_reader :cases
    def initialize(hooks={})
      @hooks = self.class::HOOKS.merge(hooks)
      @cases = Tree.new.tap{|t|t._ t, &self.class::TREESPEC}.leaves
    end

    def test
      around(cases, :start, :finish) { cases.map {|c| around(c) {c.test}}}
    end
  end
end

