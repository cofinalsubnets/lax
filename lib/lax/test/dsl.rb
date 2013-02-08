require 'minitest/unit'
module Lax
  class Test
    include MiniTest::Assertions

    class << self

      attr_reader :name

      def group(name=nil, &block)
        Class.new(self) { @name=name; class_exec(&block) if block }
      end

      def let(name, &defn)
        if name.is_a? Hash
          name.each {|k,v| let(k) {v}}
        else
          define_singleton_method(name, defn)
          define_method(name) do
            @__memo__.fetch(name) {|k| @__memo__[k] = instance_exec(&defn)}
          end
        end
      end

      def test(name=nil, &test)
        Fiber.yield new(name).__execute__ test
      end

      def assert(&test)
        test { assert instance_exec &test }
      end

      def refute(&test)
        test { refute instance_exec &test }
      end

      alias macro define_singleton_method

    end # Lax::Test singleton class

  end
end

