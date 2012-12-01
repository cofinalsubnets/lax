module Stilts
  class Runner
    autoload :Callback, 'stilts/runner/callback'
    attr_reader :done, :pool, :opts, :cases

    def initialize(cases, opts={})
      @cases, @done, @pool = cases, [], []
      @opts = { threads: 2, n: 100}.merge opts
    end

    def go
      (start=opts[:start]) and start[self]
      opts[:threads].times { thread }
      finish
    end

    def thread
      return if cases.empty?
      pool << Thread.new do
        cases.shift(opts[:n]).each { |test| done << (after run before test) }
        thread
      end
    end

    def finish
      if pool.empty?
        (cb=opts[:finish]) and cb[self] 
        return self
      end
      pool.first.join
      pool.shift
      finish
    end

    def run(c)
      begin
        c[:pass]  = c[:cond][c[:value]=c[:obj].send(c[:msg],*c[:args],&c[:blk])]
      rescue c[:xptn] => e
        c[:pass] = true
      rescue => e
        c[:pass] = false
        c[:xptn] = e
      end
      c 
    end


    def before(c)
      [opts,c].each {|h| h[:before] and h[:before][c]}
      c
    end

    def after(c)
      [c,opts].each {|h| h[:after] and h[:after][c]}
      c
    end
  end
end

