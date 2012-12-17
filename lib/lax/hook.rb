module Lax
  class Hook < Proc
    class << self
      def id; new {|i|i} end
      def pass_fail
        new {|tc|print(tc.pass ? "\x1b[32m-\x1b[0m" : "\x1b[31mX\x1b[0m")}
      end
      def summary
        new do |cs|
          puts "\nFinished #{cs.size} tests" <<
            " with #{cs.reject(&:pass).size} failures"
        end
      end
      def failures
        new {|cs| cs.reject(&:pass).each {|f| puts "  #{f.src*?:}"}}
      end

      def define(sym, &p)
        define_singleton_method(sym) {new &p}
      end

      def _compose(p1,p2)
        new {|*a,&b|p1[p2[*a,&b]]}
      end

      def _append(p1,p2)
        new {|*a,&b| p1[*a,&b];p2[*a,&b]}
      end
    end

    def <<(cb); Hook._compose self, h(cb) end
    def +(cb);  Hook._append self,  h(cb) end

    private
    def h(cb)
      Symbol===cb ? Hook.send(cb) : cb
    end

    module Run
      attr_reader :hooks
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
end

