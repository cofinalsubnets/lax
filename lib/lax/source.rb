class Lax < Array
  VERSION = '0.2.2'

  class Assertion < Struct.new :name, :subject, :condition, :src, :matcher, :args, :hooks
    def pass?
      memoize(:pass) { condition.call value }
    end

    def value
      memoize(:value) { subject.call }
    end

    def validate
      memoize(:validate) do
        hooks.before.call self
        pass?
        self.tap { hooks.after.call self }
      end
    end

    private
    def memoize(key)
      @memo ||= {}
      @memo.has_key?(key) ? @memo[key] : @memo[key] = yield
    end

    class Xptn < Struct.new :assertion, :exception
      attr_accessor :name, :src, :matcher, :args

      def pass?
        false
      end

      def value
        nil
      end

      def initialize(a, x)
        super
        %w{name src matcher args}.each {|m| send "#{m}=", a.send(m)}
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
        Hash[
          members.zip entries.map {|e| e.kind_of?(Hashable) ? e.to_hash : e }
        ]
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
        define_method($1) { satisfies($1) {|o| o.__send__ sym} }
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
      Target.new @node, ->{@subj.call.__send__(sym, *args, &blk)}, @name, @src
    end

    def __val__
      @subj.call
    end

    private
    def assert!(cond, matcher=nil, args=nil)
      name, subj, src, hooks = @name, @subj, @src, @node.hooks
      ord = @node.instance_methods.size.to_s
      @node.send(:include, ::Module.new do
        define_method(ord) do
          ::Lax::Assertion.new name, subj, cond, src, matcher, args, hooks
        end
      end)
    end

    def resolve(v)
      ::Lax::Target === v ? v.__val__ : v
    end

  end

  module Run
    def self.[](lax)
      hook = lax.config.run.hooks
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
      def _resolve(hook)
        if hook.is_a? Hook
          hook
        elsif hook.is_a? Proc
          new &hook
        elsif hook.is_a?(Symbol) and self.respond_to?(hook)
          send hook
        else
          raise NameError, "Unable to resolve hook `#{hook}'"
        end
      end

      def noop
        new {|*a|}
      end

      def output
        new {|tc| print tc.pass? ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"}
      end

      # Returns a hook for generating terminal output from test cases.
      def summary
        new {|cs| puts "\nFinished #{cs.size} tests with #{cs.reject(&:pass?).size} failures"}
      end

      # Returns a hook for generating terminal output from test cases.
      def failures
        new do |cs|
          cs.reject(&:pass?).each do |f|
            puts "  #{f.src}\n    " <<
              "#{f.exception ?
                "(raised an unhandled #{f.exception.class})" :
                "(got #{f.subject})"}"
          end
        end
      end

      def define(sym, &p)
        define_singleton_method(sym) {new &p}
      end
    end

    def <<(hook)
      Hook.new {|*a,&b| call(Hook._resolve(hook)[*a,&b])}
    end

    def +(hook)
      Hook.new {|*a,&b| call(*a,&b); Hook._resolve(hook)[*a,&b]}
    end
  end

  CONFIG = Fixture::Hashable.new(
    task: { dir: :test, name: :lax },
    node: {
      hooks: {
        before: Hook.noop,
        after:  Hook.noop
      }
    },
    run: {
      hooks: { 
        start:  Hook.noop,
        before: Hook.noop,
        after:  Hook.output,
        finish: Hook.summary
      }
    }
  )

  @hooks    = CONFIG.node.hooks
  @children = []

  def self.inherited(child)
    @children << child
    child.hooks    = @hooks.dup
    child.children = []
  end

  extend Enumerable

  class << self
    attr_accessor :hooks, :children

    def reboot(suppress_warning = true)
      (stderr, $stderr = $stderr, StringIO.new) if suppress_warning
      Object.const_set :Lax, Class.new(Array)
      Lax.const_set :SOURCE, SOURCE
      Object.class_eval SOURCE
      ($stderr = stderr) if suppress_warning
      Lax
    end

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
      children.each {|c| c.each(&b)}
    end

    def let(h)
      h.each do |key, value|
        val = value.is_a?(Hook) ? value : ->{value}
        define_singleton_method(key) do
          Target.new(self, val, key, caller[0])
        end
      end
    end

    def defer(&v)
      Hook.new(&v)
    end
    alias _ defer

    def fix(hash)
      Fixture.new(hash)
    end

    def assert(*vals, &b)
      Class.new(self).tap {|node| node.class_eval(&b)}
    end
  end

  def initialize
    ks = methods - self.class.superclass.instance_methods
    ks.map {|k| send k}.each {|k| self << k}
  end
end

