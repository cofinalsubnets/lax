class Lax
  module Output
    DOTS     = ->(tc=[]) {tc.each {|c| print (c&&!c.is_a?(Exception)) ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}}
    SUMMARY  = ->(cs=[]) { puts "pass: #{cs.select{|c|c==true}.size}\nfail: #{cs.reject{|c|c==true}.size}"}
    FAILURES = ->(cs=[]) do
      puts
      cs.reject{|c|c.first==true}.each do |f|
        puts "  failure in #{f.last.doc || 'an undocumended node'} at #{f.last.src.split(/:in/).first}"
        puts "    raised #{f.first.class} : #{f.first.message}" if Exception===f.first
      end
    end
  end
end

