module Lax
  class Hook < Proc
    class << self
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
    end
    def <<(cb); Hook.new {|e| call cb[e]}    end
    def +(cb);  Hook.new {|e| call e; cb[e]} end
  end
end

