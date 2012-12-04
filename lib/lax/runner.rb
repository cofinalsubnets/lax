module Lax
  # Runner for test cases. Handles callbacks, concurrency, etc.
  class Runner
    attr_reader :cases
    # Takes an array of test cases and an optional hash of options.
    def initialize(cases, opts={})
      @cases, @opts = cases, {threads: 1}.merge(opts)
    end

    def go
      (start=@opts[:start]) and start[self]
      todo = cases.dup
      (1..@opts[:threads]).map do
        Thread.new {run todo.shift while todo.any?}
      end.each &:join
      (finish=@opts[:finish]) and finish[self]
      self
    end

    private
    def run(c)
      @opts[:before][c] if @opts[:before]
      c.run
      @opts[:after][c] if @opts[:after]
    end
  end
end

