module Lax
  class Hook < Proc
    def <<(cb); Hook.new {|e| self[cb[e]]}    end
    def +(cb);  Hook.new {|e| self[e]; cb[e]} end

    StartTime = Hook.new do |rn|
      rn.extend(Module.new {attr_accessor :start, :stop}).start = Time.now
    end

    StopTime  = Hook.new {|rn| rn.stop = Time.now }

    SimpleOut = Hook.new {|tc| $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")}

    Summary   = Hook.new do |rn|
      puts "\nFinished #{(cs=rn.cases).size} tests" <<
        " in #{(rn.stop - rn.start).round 10} seconds" <<
        " with #{(cs.reject{|c|c[:pass]}).size} failures"
    end

    FailList  = Hook.new do |rn|
      rn.cases.reject {|c|c[:pass]}.each do |f|
        puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
          "#{?(+[*f[:args]]*', '+?) if f[:args]} " << (f.has_key?(:value) ? "#=> #{f[:value]}" : "raised unhandled #{f[:xptn].class}")
      end
    end
  end
end
