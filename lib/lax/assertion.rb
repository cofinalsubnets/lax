class Lax
  class Assertion < Struct.new(:__pass__, :__exception__, :__memo__)
    include Fixture
    extend  Fixture, Enumerable

    class << self
      def scope(doc=nil,&b)
        Class.new(self, &b).tap {|k| define_method(:__doc__) {doc}}
      end

      def let(name, &defn)
        if name.is_a? Hash
          name.each {|k,v| let(k) {v}}
        else
          define_singleton_method(name, defn)
          define_method(name) do
            __memo__.has_key?(name)? __memo__[name] : __memo__[name] = instance_exec(&defn)
          end
        end
      end

      def before(&bef)
        mtd = instance_method :__before__
        define_method :__before__ do
          mtd.bind(self).call
          instance_exec &bef
        end
      end

      def after(&aft)
        mtd = instance_method :__after__
        define_method :__after__ do
          instance_exec &aft
          mtd.bind(self).call
        end
      end

      def condition(name, &cond)
        define_singleton_method(name) do |*as,&blk|
          scope do
            define_method(:__test__, cond.curry.call(*as))
            define_method(:__subject__, blk)
          end
        end
      end

      def inherited(klass)
        children << klass
      end

      def each(&b)
        yield self
        children.each {|c| c.each(&b)}
      end

      def children
        @children ||= []
      end

      def concrete?
        [:__subject__, :__test__].all? {|m| instance_methods.include? m}
      end

      alias macro define_singleton_method
    end

    condition(:assert) {|n|  n}
    condition(:refute) {|n| !n}

    def __before__; end
    def __after__;  end

    def initialize
      self.__memo__ = {}
      __execute__
    end

    def __source__
      method(:__subject__).source_location
    end

    private
    def __execute__
      __before__
      self.__pass__ = __test__ __subject__
    rescue => e
      self.__exception__ = e
    ensure
      __after__
    end
  end
end

