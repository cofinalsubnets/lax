module Stilts
  # Runner for test cases. Handles callbacks, concurrency, etc.
  class Runner
    attr_reader :cases
    # Takes an array of test cases and an optional hash of options.
    def initialize(cases, opts={})
      @todo, @cases, @opts = cases, [], {threads: 1}.merge(opts)
    end

    def go
      (start=@opts[:start]) and start[self]
      (1..@opts[:threads]).map do
        Thread.new do
          cases << (after run before @todo.shift) while @todo.any?
        end
      end.each &:join
      (finish=@opts[:finish]) and finish[self]
      self
    end

    private
    def run(c)
      begin
        c[:pass] = c[:cond][c[:value]=c[:obj].__send__(c[:msg],*c[:args],&c[:blk])]
      rescue c[:xptn] => e
        c[:pass] = true
      rescue => e
        c[:pass] = false
        c[:xptn] = e
      end
      c 
    end

    def before(c)
      [@opts,c].each {|h| h[:before] and h[:before][c]}
      c
    end

    def after(c)
      [c,@opts].each {|h| h[:after] and h[:after][c]}
      c
    end
  end
end

