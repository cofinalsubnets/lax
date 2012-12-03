module Stilts
  class CB < Proc
    def <<(cb); CB.new {|e| self[cb[e]]}    end
    def +(cb);  CB.new {|e| self[e]; cb[e]} end

    StartTime = CB.new { @start = Time.now }
    StopTime  = CB.new { @stop  = Time.now }

    SimpleOut = CB.new do |tc|
      $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")
    end

    Summary   = CB.new do |rn|
      puts "\nFinished #{(cs=rn.cases).size} tests" <<
        " in #{(@stop - @start).round 10} seconds" <<
        " with #{(fs=cs.select{|c|!c[:pass]}).size} failures"
    end

    FailList  = CB.new do |rn|
      fs = rn.cases.select{|c|!c[:pass]}
      fs.each do |f|
        puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
          "#{?(+[*f[:args]]*', '+?) if f[:args]} " << (f.has_key?(:value) ? "#=> #{f[:value]}" : "raised unhandled #{f[:xptn].class}")
      end
    end
  end
end

