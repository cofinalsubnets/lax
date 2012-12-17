module Lax
  class Runner
    include Hook::Run
    attr_reader :groups
    def initialize(groups=Group::DEFS, hooks={})
      @groups, @hooks = groups, Lax.recursive_merge(Lax.config[:runner], hooks)
    end

    def go
      around(groups, :start, :finish) do
        groups.map {|g| around(g) {g.new(hooks[:group]).test}}.flatten
      end
    end
  end
end

