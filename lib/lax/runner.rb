module Lax
  class Runner
    include Hook::Run
    DEFAULT_HOOKS = {finish: (Hook.summary+Hook.failures)<<proc{|gs|gs.map(&:cases).flatten}}
    DEFAULT_GROUP_HOOKS = {after: Hook.pass_fail}
    attr_reader :groups, :opts, :group_hooks
    def initialize(opts={})
      @hooks       = DEFAULT_HOOKS.merge(opts.delete(:hooks)||{})
      @group_hooks = DEFAULT_GROUP_HOOKS.merge(@hooks.delete(:group)||{})
      @groups      = opts.delete(:groups).map {|g| g.new group_hooks}
      @opts        = opts
    end

    def go
      around(groups, :start, :finish) { groups.each {|g| around(g) {g.test;g}}}
    end
  end
end

