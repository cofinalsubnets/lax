class Lax
  DOTS     = ->(tc) {print tc.pass? ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}
  SUMMARY  = ->(cs) { puts "pass: #{cs.select(&:pass?).size}\nfail: #{cs.reject(&:pass?).size}"}
  FAILURES = ->(cs) do
    puts
    cs.reject(&:pass?).each do |f|
      puts "  in #{f.doc or 'an undocumented node'} at #{f.src.split(/:in/).first}"
      puts "    #{f.show} #=> " <<
        (f.kind_of?(Assertion::Xptn) ?  "unhandled #{f.exception.class}: #{f.exception.message}": "#{f.value}")
    end
  end
end

