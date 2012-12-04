module Lax
  class Hook < Proc
    def <<(cb); Hook.new {|e| self[cb[e]]}    end
    def +(cb);  Hook.new {|e| self[e]; cb[e]} end

    StartTime = Hook.new { @start = Time.now }
    StopTime  = Hook.new { @stop  = Time.now }

    SimpleOut = Hook.new do |tc|
      $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")
    end

    Summary   = Hook.new do |rn|
      puts "\nFinished #{(cs=rn.cases).size} tests" <<
        " in #{(@stop - @start).round 10} seconds" <<
        " with #{(fs=cs.select{|c|!c[:pass]}).size} failures"
    end

    FailList  = Hook.new do |rn|
      fs = rn.cases.select{|c|!c[:pass]}
      fs.each do |f|
        puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
          "#{?(+[*f[:args]]*', '+?) if f[:args]} " << (f.has_key?(:value) ? "#=> #{f[:value]}" : "raised unhandled #{f[:xptn].class}")
      end
    end
  end
end

