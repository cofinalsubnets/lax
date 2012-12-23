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
        pass?
        self.tap { node.hooks.after.call self }
      end
    end

    private
    def memoize(key)
      (@memo||={}).has_key?(key) ? @memo[key] : @memo[key] = yield
    end

    class Xptn < Struct.new :assertion, :exception, :pass?, :value
      attr_accessor :target, :src, :matcher, :args, :node
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
          satisfies(sym) do |o|
            p[*a.map {|v| resolve v},&b][o]
          end :
          satisfies(sym,*a) do |o|
            o.__send__ sym,*a.map {|v| resolve v},&b
          end
      end
    end

    def self.define_predicate(sym)
      if sym =~ /(.*)(\?|_?p)$/
        define_method($1) {|*a,&b| satisfies($1) {|o| o.__send__ sym,*a,&b} }
      else
        raise ArgumentError, "#{sym} does not appear to be a predicate"
      end
    end

    %w{== === != =~ !~ < > <= >=}.each {|m| define_matcher m}
    %w{odd? even? is_a? kind_of? include?}.each {|m| define_predicate m}

    def initialize(node, subj, name, src)
      @node, @subj, @init, @name, @src = node, subj, subj, name, src 
    end

    def satisfies(matcher=nil, *args, &cond)
      assert!(cond, *[ matcher, args ])
    end

    def method_missing(sym, *args, &blk)
      s, @subj = @subj, ->{s.call.__send__ sym, *args, &blk}
      self
    end

    def __val__
      @subj.call
    end

    private
    def assert!(cond, matcher=nil, args=nil)
      name, subj, src, node, @subj = @name, @subj, @src, @node, @init
      ord = @node.instance_methods.size.to_s
      @node.send(:include, ::Module.new do
        define_method(ord) do
          ::Lax::Assertion.new name, subj, cond, src, matcher, args, node
        end
      end)
    end

    def resolve(v)
      ::Lax::Target === v ? v.__val__ : v
    end

  end

  module Run
    def self.[](lax)
      hook = lax.config.run
      hook.start[ as = lax.map(&:new).flatten ]
      as.map do |assertion|
        hook.before[ assertion ]
        validate_protect(assertion).tap {|v| hook.after[v]}
      end.tap {|vs| hook.finish[vs]}
    end

    private
    def self.validate_protect(a)
      begin
        a.validate
      rescue => e
        Assertion::Xptn.new(a, e)
      end
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
      after:  Hook.noop
    },
    run: {
      start:  Hook.noop,
      before: Hook.noop,
      after:  Hook.noop,
      finish: Hook.noop
    }
  )

  @hooks, @lings, @targets = CONFIG.node, [], {}

  def self.inherited(ling)
    @lings << ling
    ling.hooks   = @hooks.dup
    ling.lings   = []
    ling.targets = {}
  end

  extend Enumerable

  class << self
    attr_accessor :hooks, :lings, :doc, :targets

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
          @targets[key] ||= Target.new(self, val, key, caller[0])
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
      Class.new(self).tap do |node|
        node.doc = doc
        node.class_eval(&b)
      end
    end
  end

  def initialize
    ks = methods - self.class.superclass.instance_methods
    ks.map {|k| send k}.each {|k| self << k}
  end
end

