class Lax < Struct.new(:pass, :exception)
  VERSION = '0.2.4'
  Lazy    = Class.new Proc

  extend Enumerable
  @lings = []
  def self.inherited(ling)
    @lings << ling
    ling.lings = []
  end

  class << self
    attr_accessor :lings, :assertion
    def lazy;         Lazy.new                               end
    def assert(&b);   Class.new(self, &b)                    end
    def before(&bef); mcompose instance_method(:before), bef end
    def after(&aft);  mcompose instance_method(:after),  aft end
    def fix(hash); Struct.new(*hash.keys).new *hash.values   end

    def let(h)
      h.each do |key, value|
        val = (Lazy===value) ? value : lazy{value}
        define_singleton_method(key, val)
        define_method(key) do
          (@_memo||={}).has_key?(key)? @_memo[key] : @_memo[key] = val.call
        end
      end
    end

    def that(&spec)
      assert { include @assertion = Assertion.new(spec) }
    end

    def each(&b)
      yield self
      lings.each {|ling| ling.each(&b)}
    end

    private
    def mcompose(mtd, prc)
      define_method(mtd.name) {instance_exec(&prc); mtd.bind(self).call}
    end
  end

  def before(*a); end
  def after(*a);  end

  class Assertion < Module
    def initialize(spec)
      define_method(:source) { spec.source_location }
      define_method :initialize do
        before
        begin
          self.pass = instance_eval(&spec)
        rescue => e
          self.exception = e
        ensure
          after
        end
      end
    end
  end

  module RakeTask
    def self.new(opts = {})
      require 'rake'
      extend Rake::DSL
      o = {dir: :test, name: :lax}.merge(opts)
      namespace o[:name] do
        task(:load) { Dir["./#{o[:dir]}/**/*.rb"].each {|f| load f} }
        task(:run) do
          Lax.after &Output::DOTS
          ->(n){Output::FAILURES[n]; Output::SUMMARY[n]}.call Lax.select(&:assertion).map &:new
        end
      end
      task o[:name] => ["#{o[:name]}:load", "#{o[:name]}:run"]
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

