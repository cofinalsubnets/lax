class Lax < Array
  VERSION = '0.2.3'

  Lazy = Class.new Proc
  Assertion = Struct.new(:pass, :source, :doc, :exception)

  @lings = []
  extend Enumerable
  def self.inherited(ling)
    @lings << ling
    ling.lings = []
  end

  class << self
    attr_accessor :lings, :src, :doc

    def each(&b)
      yield self
      lings.each {|c| c.each(&b)}
    end

    def let(h)
      h.each do |key, value|
        val = (Lazy===value) ? value : lazy{value}
        define_singleton_method(key) do |&b|
          b ? assert { that val.call.instance_exec(&b) } : val.call
        end
        define_method(key) do
          (@_memo||={}).has_key?(key)? @_memo[key] : @_memo[key] = val.call
        end
      end
    end

    def lazy
      Lazy.new
    end

    def fix(hash)
      Struct.new(*hash.keys).new *hash.values
    end

    def before(&bef)
      ->(m) { define_method(:before) do |*a|
        m.bind(self).call *a
        instance_exec(*a, &bef)
      end }.call instance_method :before
    end

    def assert(doc=nil,&spec)
      scope do
        @doc, @src = doc, spec.source_location
        include AssertionGroup
        before(&spec)
      end
    end

    def scope(&b)
      Class.new(self, &b)
    end

    def run(hook=->(n){n})
      hook.call map(&:new).flatten
    end

    def after(&aft)
      ->(m) { define_method(:after) do |*a|
        instance_exec(*a, &aft)
        m.bind(self).call *a
      end }.call instance_method :after
    end

    def matcher(sym,&p)
      define_method(sym) { satisfies &p}
    end
  end

  def before(*a); end
  def after(*a);  end

  module AssertionGroup
    def fix(hash)
      self.class.fix hash
    end

    def that(*as)
      concat as.map {|a| assert a}
    end

    def satisfies
      push assert yield pop
    end

    def assert(v,x=nil)
      Assertion.new !!v, self.class.src, self.class.doc, x
    end

    def initialize
      before
    rescue => e
      push assert(false, e)
    ensure
      after self
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
          Lax.run ->(n){Output::FAILURES[n]; Output::SUMMARY[n]}
        end
      end
      task o[:name] => ["#{o[:name]}:load", "#{o[:name]}:run"]
    end
  end

  module Output
    DOTS = ->(tc) {
      tc.each {|c| print c.pass ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}
    }

    SUMMARY = ->(cs) {
      puts "pass: #{cs.select(&:pass).size}\nfail: #{cs.reject(&:pass).size}"
    }
    FAILURES = ->(cs) {
      puts
      cs.reject(&:pass).each do |f|
        puts "  failure in #{f.doc || 'an undocumended node'} at #{f.source*?:}"
        puts "    raised #{f.exception.class} : #{f.exception.message}" if f.exception
      end
    }
  end
end

