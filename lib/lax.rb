class Lax < Struct.new(:pass, :exception)
  VERSION = '0.2.4'
  Lazy    = Class.new Proc
  @lings  = []

  extend Enumerable
  def self.inherited(ling)
    @lings << ling
    ling.lings = []
  end

  class << self
    attr_accessor :lings, :assertion
    def lazy
      Lazy.new   
    end

    def assert(&b)
      Class.new(self, &b)    
    end

    def fix(hash)
      Struct.new(*hash.keys).new *hash.values 
    end

    def let(h)
      h.each do |key, value|
        val = (Lazy===value) ? value : lazy{value}
        define_singleton_method(key, val)
        define_method(key) do
          (@_memo||={}).has_key?(key)? @_memo[key] : @_memo[key] = val.call
        end
      end
    end

    def before(&bef)
      ->(m) { define_method :before do
        m.bind(self).call
        instance_exec &bef
      end }.call instance_method :before
    end

    def after(&aft)
      ->(m) { define_method :after do
        instance_exec &aft
        m.bind(self).call
      end }.call instance_method :after
    end

    def that(&spec)
      assert { include @assertion = Assertion.new(spec) }
    end

    def each(&b)
      yield self
      lings.each {|ling| ling.each(&b)}
    end
  end

  def before; end
  def after;  end

  class Assertion < Module
    def initialize(spec)
      define_method(:source) { spec.source_location }
      define_method :initialize do
        before
        begin
          self.pass = instance_eval(&spec)
        rescue => e
          self.exception = e
        end
        after
      end
    end
  end

  module RakeTask
    def self.new(opts = {})
      require 'rake'
      extend Rake::DSL
      o = {dir: :test, name: :lax}.merge(opts)
      task o[:name] do
        Dir["./#{o[:dir]}/**/*.rb"].each {|f| load f}
        Lax.after &Output::DOTS
        ->(n){Output::FAILURES[n]; Output::SUMMARY[n]}.call Lax.select(&:assertion).map(&:new)
      end
    end
  end

  module Output
    DOTS     = ->{print pass ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}
    SUMMARY  = ->(cs) {puts "pass: #{cs.select(&:pass).size}\nfail: #{cs.reject(&:pass).size}"}
    FAILURES = ->(cs) do
      puts
      cs.reject(&:pass).each do |f|
        puts "  failure at #{f.source*?:}"
        puts "    raised #{f.exception.class} : #{f.exception.message}" if f.exception
      end
    end
  end
end

