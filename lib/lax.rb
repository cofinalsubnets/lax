class Lax < Array
  VERSION = '0.2.2'

  class Assertion < Struct.new :target, :subject, :condition, :src, :matcher, :args, :node
    def pass?
      memoize(:pass) { condition.call value }
    end

    def value
      memoize(:value) { subject.call }
    end

    def validate
      memoize(:validate) do
        node.hooks.before.call self
        begin
          pass?
          tap { node.hooks.after.call self }
        rescue => e
          Xptn.new(self, e)
        end
      end
    end

    private
    def memoize(key)
      (@memo||={}).has_key?(key) ? @memo[key] : @memo[key] = yield
    end

    class Xptn < Struct.new :assertion, :exception
      attr_accessor :target, :src, :matcher, :args, :node
      def pass?; nil end
      def value; nil end
      def initialize(a, x)
        super
        %w{target src matcher args node}.each {|m| send "#{m}=", a.send(m)}
      end
    end
  end

  module Fixture
    def self.new(hash)
      klass = Struct.new(*hash.keys)
      klass.send :include, self
      klass.new *hash.values
    end

    module Hashable
      def self.new(hashable)
        hash = hashable.to_hash
        klass = Struct.new(*hash.keys)
        klass.send :include, self, Fixture
        klass.new(*hash.values.map do |val|
          (Hash===val) ? new(val) : val
        end)
      end

      def to_hash
        Hash[ members.zip entries.map {|e| e.kind_of?(Hashable) ? e.to_hash : e } ]
      end

      def merge(hashable)
        Hashable.new to_hash.merge hashable
      end
    end
  end

  class Target < BasicObject
    def self.define_matcher(sym, &p)
      define_method(sym) do |*a,&b|
        p ? 
          satisfies(sym) {|o| p[*rslv(a),&b][o] } :
          satisfies(sym,*a) {|o| o.__send__ sym,*rslv(a),&b }
      end
    end

    def self.define_predicate(sym)
      if sym =~ /(.*)(\?|_?p)$/
        define_method($1) {|*a,&b| satisfies($1) {|o| o.__send__ sym,*rslv(a),&b} }
      else
        raise ArgumentError, "#{sym} does not appear to be a predicate"
      end
    end

    %w{== === != =~ !~ < > <= >=}.each {|m| define_matcher m}
    %w{odd? even? is_a? kind_of? include?}.each {|m| define_predicate m}

    def initialize(node, subj, name, src)
      @node, @subj, @name, @src = node, subj, name, src 
    end

    def satisfies(matcher=nil, *args, &cond)
      assert!(cond, *[ matcher, args ])
    end

    def method_missing(sym, *args, &blk)
      ::Lax::Target.new @node, ->{@subj.call.__send__ sym, *rslv(args), &blk}, @name, @src
    end

    def __val__
      @subj.call
    end

    private
    def assert!(cond, matcher=nil, args=nil)
      name, subj, src = @name, @subj, @src
      @node.hooks.init += ->(node){node.push ::Lax::Assertion.new(name, subj, cond, src, matcher, args, node.class)}
    end

    def rslv(vs)
      vs.map {|v| ::Lax::Target === v ? v.__val__ : v}
    end

  end


  class Hook < Proc
    class << self
      def noop
        new {|*a|}
      end

      def output
        new {|tc| print tc.pass? ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}
      end

      def summary
        new {|cs| puts "pass: #{cs.select(&:pass?).size}\nfail: #{cs.reject(&:pass?).size}"}
      end

      def failures
        new do |cs|
          puts
          cs.reject(&:pass?).each do |f|
            puts "  in #{f.node.doc or 'an undocumented node'} at #{f.src.split(/:in/).first}"
            puts "    an assertion on #{f.target} failed#{" to satisfy #{f.matcher}(#{f.args.join ', '})" if f.matcher}"
            Assertion::Xptn === f ?
              puts("    with an unhandled #{f.exception.class}: #{f.exception.message}"):
              puts("    with its return value: #{f.value}")
          end
        end
      end

      def prototype
        new {|node| node.class.lings.each {|ling| node.push ling.new }}
      end

      def define(sym, &p)
        define_singleton_method(sym) {new &p}
      end
    end

    def <<(hook)
      Hook.new {|*a,&b| call(resolve(hook)[*a,&b])}
    end

    def +(hook)
      Hook.new {|*a,&b| call(*a,&b);resolve(hook)[*a,&b]}
    end

    private
    def resolve(hook)
      Proc===hook ? hook : Hook.send(hook)
    end
  end

  CONFIG = Fixture::Hashable.new(
    task: { dir: :test, name: :lax },
    node: {
      before: Hook.noop,
      after:  Hook.noop,
      init:   Hook.prototype
    },
    run: {
      start:  Hook.noop,
      before: Hook.noop,
      after:  Hook.noop,
      finish: Hook.noop
    }
  )

  @hooks, @lings = CONFIG.node, []

  def self.inherited(ling)
    @lings << ling
    ling.hooks      = @hooks.dup
    ling.hooks.init = Hook.prototype
    ling.lings      = []
  end

  extend Enumerable

  class << self
    attr_accessor :hooks, :lings, :doc

    def config
      block_given? ? yield(CONFIG) : CONFIG
    end

    def matcher(sym, &b)
      Target.define_matcher(sym, &b)
    end

    def hook(sym, &b)
      Hook.define(sym, &b)
    end

    def each(&b)
      yield self
      lings.each {|c| c.each(&b)}
    end

    def before(&b)
      hooks.before += b
    end

    def after(&b)
      hooks.after += b
    end

    def let(h)
      h.each do |key, value|
        val = (Hook===value) ? value : (Target===value) ? defer{value.__val__} : ->{value}
        define_singleton_method(key) do
          Target.new(self, val, key, caller[0])
        end
      end
    end

    def defer(&v)
      Hook.new(&v)
    end

    def fix(hash)
      Fixture.new(hash)
    end

    def assert(doc=nil, &b)
      Class.new(self) do
        self.doc = doc
        class_eval(&b)
      end
    end

    def validate
      config.run.start.call(as = new.flatten)
      as.map do |a|
        config.run.before.call a
        a.validate.tap {|a| config.run.after.call a}
      end.tap {|as| config.run.finish.call as}
    end
  end

  def initialize
    self.class.hooks.init.call self
  end
end

