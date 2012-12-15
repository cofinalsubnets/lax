module Lax
  class Hook < Proc
    def <<(cb); Hook.new {|e| call cb[e]}    end
    def +(cb);  Hook.new {|e| call e; cb[e]} end

    StartTime = Hook.new { @start = Time.now }
    StopTime  = Hook.new { @stop  = Time.now }
    PassFail  = Hook.new {|tc| print(tc.pass ? "\x1b[32m-\x1b[0m" : "\x1b[31mX\x1b[0m")}

    Summary   = Hook.new do |cases|
      puts "\nFinished #{cases.size} tests" <<
        " in #{(@stop - @start).round 10} seconds" <<
        " with #{cases.reject(&:pass).size} failures"
    end

    Failures  = Hook.new do |cases|
      cases.reject(&:pass).each {|f| puts "  #{f.source}"}
    end
  end
end

