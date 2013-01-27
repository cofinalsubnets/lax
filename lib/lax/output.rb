class Lax
  module Output
    def self.dots(c)
      print c.__pass__ ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"
    end

    def self.summarize(cs)
      puts
      cs.reject(&:__pass__).each do |f|
        puts "  failure in #{f.__doc__ || 'an undocumented node'} at #{f.__source__*?:}"
        puts "    raised #{f.__exception__.class} : #{f.__exception__.message}" if f.__exception__
      end
      puts "pass: #{cs.select(&:__pass__).size}\nfail: #{cs.reject(&:__pass__).size}"
    end
  end
end

