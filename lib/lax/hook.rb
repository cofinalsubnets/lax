module Lax
  class Hook < Proc
    class << self
      def time_start; new { @start = Time.now } end
      def time_stop;  new { @stop  = Time.now } end
      def pass_fail(opts={})
        opts = { pass: "\x1b[32m-\x1b[0m", fail:  "\x1b[31mX\x1b[0m"}.merge opts
        new {|tc|print(tc.pass ? opts[:pass] : opts[:fail])}
      end
      def summary(timed=false)
        new do |cases|
          puts "\nFinished #{cases.size} tests" <<
            (timed ? " in #{(@stop - @start).round 10} seconds" : '') <<
            " with #{cases.reject(&:pass).size} failures"
        end
      end
      def failures
        new {|cases| cases.reject(&:pass).each {|f| puts "  #{f.source}"}}
      end
    end
    def <<(cb); Hook.new {|e| call cb[e]}    end
    def +(cb);  Hook.new {|e| call e; cb[e]} end

    module Run
      attr_reader :hooks
      private
      def around(init=nil, h1=:before, h2=:after)
        run_hook h1, init
        yield.tap{|v|run_hook h2,v}
      end

      def run_hook(h, *as)
        hooks[h][*as] if hooks and hooks[h]
      end
    end
  end
end

