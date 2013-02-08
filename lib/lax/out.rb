module Lax
  # A very elementary set of output methods for test results.
  module Out

    RED   = "\x1b[31m"
    GREEN = "\x1b[32m"
    CLEAR = "\x1b[0m"

    OK = "."
    NO = "X"

    PASS = GREEN + OK + CLEAR
    FAIL = RED   + NO + CLEAR

    # The default 'after-each' test formatter. Green dots aww yeah...
    def self.dots(r)
      print r.pass? ? PASS : FAIL
    end

    # The default 'after-all' test formatter. Displays a list of failures.
    def self.summary(rs)
      newline
      list_failures rs
      count rs
    end

    def self.count(rs)
      puts "#{rs.size} tests, #{rs.select(&:fail?).size} failures."
    end

    def self.newline
      puts
    end

    def self.list_failures(rs)
      rs.select(&:fail?).each_with_index { |f,i| show_failure f, i }
    end

    def self.name_test(r)
      r.name || 'an anonymous test'
    end

    def self.name_group(r)
      r.context || 'an anonymous test group'
    end

    def self.source(f)
      f.source_location*?:
    end

    def self.show_failure(f, i)
      puts "#{i}:  #{name_test f} in #{name_group f} at #{source f}"
      puts "    #{f.failure.class}:#{f.failure.message}"
      show_backtrace f
    end

    def self.show_backtrace(f)
      unless f.failure.is_a? MiniTest::Assertion
        puts f.failure.backtrace.map {|b| "      #{b}"}.join(?\n)
      end
    end

    class << self
      alias [] method
    end
  end
end

