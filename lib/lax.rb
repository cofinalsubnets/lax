require 'lax/version'
class Lax < Array
  autoload :Assertion, 'lax/assertion'
  autoload :Fixture,   'lax/fixture'
  autoload :Target,    'lax/target'

  @lings = []
  def self.inherited(ling)
    @lings << ling
    ling.lings = []
  end

  extend Enumerable

  class << self
    attr_accessor :hooks, :lings, :doc, :prototype

    def matcher(sym, &b)
      Target.define_matcher(sym, &b)
    end

    def each(&b)
      yield self
      lings.each {|c| c.each(&b)}
    end

    def let(h)
      h.each do |key, value|
        val = (Defer===value) ? value : (Target===value) ? defer{value.__val__} : defer{value}
        define_singleton_method(key, val)
        define_method(key, ->{Target.new(self, val, key, caller[0])})
      end
    end

    def defer(&v)
      Defer.new(&v)
    end

    def fix(hash)
      Fixture.new(hash)
    end

    def scope(doc=nil, &b)
      Class.new(self, &b).tap {|c| c.doc = doc}
    end

    def assert(&spec)
      self.prototype = ->(n) { n.instance_exec &spec }
    end

    def validate
      _start(ls = map(&:new))
      _finish ls.flat_map(&:validate)
    end

    def _start(*a);  end
    def _finish(*a); end

    def before(&bef)
      before = instance_method(:before)
      define_method(:before) do |a|
        before.bind(self).call a
        instance_exec(a, &bef)
      end
    end

    def after(&aft)
      after = instance_method(:after)
      define_method(:after) do |a|
        instance_exec(a, &aft)
        after.bind(self).call a
      end
    end

    def start(&strt)
      start = method(:_start).unbind
      define_singleton_method(:_start) do |a|
        start.bind(self).call a
        class_exec(a, &strt)
      end
    end

    def finish(&fin)
      finish = method(:_finish).unbind
      define_singleton_method(:_finish) do |a|
        class_exec(a, &fin)
        finish.bind(self).call a
      end
    end

  end

  def initialize
    begin
      before
      (p=self.class.prototype) and p.call(self)
    rescue => e
      push Assertion::Exception::Toplevel.new(self.class.doc, e)
    end
  end

  def validate
    map(&:validate).each {|a| after a}
  end

  def after(*a);  end
  def before(*a); end
  class Defer < Proc; end
end

