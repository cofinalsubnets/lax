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
      todo = @cases.dup
      (1..@opts[:threads]).map do
        Thread.new {run todo.shift while todo.any?}
      end.each &:join
      (finish=@opts[:finish]) and finish[self]
      self
    end

    private
    def run(c)
      [@opts,c].each {|h| h[:before] and h[:before][c]}
      begin
        c[:pass] = c[:cond][c[:value]=c[:obj].__send__(c[:msg],*c[:args],&c[:blk])]
      rescue c[:xptn] => e
        c[:pass] = true
      rescue => e
        c[:pass] = false
        c[:xptn] = e
      end
      [c,@opts].each {|h| h[:after] and h[:after][c]}
    end
  end
end

