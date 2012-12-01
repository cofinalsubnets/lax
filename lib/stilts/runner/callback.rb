module Stilts
  class Runner
    class Callback < Proc
      def initialize(&b)
        super &b
      end

      def compose(cb)
        Callback.new {|e| self[cb[e]]}
      end

      def append(cb)
        Callback.new {|e| self[e]; cb[e]}
      end
      alias << compose
      alias +  append

      StartTime = Callback.new {|tc| tc[:start] = Time.now }
      StopTime  = Callback.new {|tc| tc[:stop]  = Time.now }

      SimpleOut = Callback.new do |tc|
        $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")
      end

      Summary   = Callback.new do |rn|
        puts "\nFinished #{(cs=rn.done).size} tests" <<
          " in #{cs.reduce(0) {|s,c| s+(c[:stop]-c[:start])}.round 10} seconds" <<
          " with #{(fs=cs.select{|c|!c[:pass]}).size} failures"
      end

      FailList  = Callback.new do |rn|
        fs = rn.done.select{|c|!c[:pass]}
        fs.each do |f|
          puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
            "#{" failed to satisfy a condition defined on #{f[:cond].source_location*?:}" if f[:cond]}"
        end
      end
    end
  end
end
