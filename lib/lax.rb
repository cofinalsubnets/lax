class Lax < Struct.new(:pass, :exception)
  VERSION = '0.2.4'
  @lings  = []

  extend Enumerable
  def self.inherited(ling)
    @lings << ling
    ling.lings = []
  end

  class << self
    attr_accessor :lings, :assertion
    def assert(&b)
      Class.new(self, &b)    
    end

    def fix(hash)
      Struct.new(*hash.keys).new *hash.values 
    end

    def let(name, &defn)
      if name.is_a? Hash
        name.each {|k,v| let(k) {v}}
      else
        define_singleton_method(name, defn)
        define_method(name) do
          (@_memo||={}).has_key?(name)? @_memo[name] : @_memo[name] = defn.call
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
      assert { include Assertion.new(spec) }
    end

    def each(&b)
      yield self
      lings.each {|ling| ling.each(&b)}
    end

    def condition(name, &cond)
      define_singleton_method(name) do |&blk|
        assert { include Assertion.new(proc {cond.call blk.call}, cond.source_location) }
      end
    end
  end

  def before; end
  def after; end

  class Assertion < Module
    def initialize(spec, src = spec.source_location) 
      define_singleton_method(:included) {|k| k.assertion = self }
      define_method(:source) {src}
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

