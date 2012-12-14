module Lax
  class Hook < Proc
    def <<(cb); Hook.new {|e| self[cb[e]]}    end
    def +(cb);  Hook.new {|e| self[e]; cb[e]} end

    StartTime = Hook.new { @start = Time.now }
    StopTime  = Hook.new { @stop  = Time.now }
    PassFail  = Hook.new {|tc| $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")}

    Summary   = Hook.new do |cases|
      puts "\nFinished #{cases.size} tests" <<
        " in #{(@stop - @start).round 10} seconds" <<
        " with #{(cases.reject{|c|c[:pass]}).size} failures"
    end

    Failures  = Hook.new do |cases|
      cases.reject {|c|c[:pass]}.each do |f|
        puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
          "#{?(+[*f[:args]]*', '+?) if f[:args]} " << (f.has_key?(:value) ? "#=> #{f[:value]}" : "raised unhandled #{f[:xptn].class}")
      end
    end
  end
end

