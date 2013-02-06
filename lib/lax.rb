require 'fiber'
require 'minitest/unit'
module Lax
  VERSION = '0.3.0'

  class Test
    include MiniTest::Assertions

    class << self
      attr_reader :name

      def scope(name=nil, &block)
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

      def before(&bef)
        mtd = instance_method :__before__

        define_method :__before__ do
          mtd.bind(self).call
          instance_exec(&bef)
        end
      end

      def after(&aft)
        mtd = instance_method :__after__

        define_method :__after__ do
          instance_exec(&aft)
          mtd.bind(self).call
        end
      end

      alias macro define_singleton_method

      def assert(name=nil, &test)
        Fiber.yield new(name).__execute__ test
      end

      def execute(files)
        Enumerator.new do |yielder|
          reader, results = reader(files), []

          while reader.alive?
            if (r=reader.resume).is_a?(Result)
              yielder << r
              results << r
            end
          end

          results
        end
      end

      def fix(hash)
        Struct.new(*hash.keys).new(*hash.values)
      end

      private

      def reader(files)
        Fiber.new do 
          files.each do |file|
            scope { instance_eval File.read(file), File.expand_path(file) }
          end
        end
      end
    end # Lax::Test singleton class

    def __before__; end
    def __after__;  end

    def initialize(name=nil)
      @__memo__, @__name__ = {}, name
    end

    def fix(hash)
      self.class.fix(hash)
    end

    def that(obj)
      Target.new(obj)
    end

    def __execute__(test)
      args = [@__name__, self.class.name, test.source_location]

      __before__
      instance_exec(&test)
      Result.new(*args)

    rescue Exception => e
      Result.new(*args, e)

    ensure
      __after__

    end

    class Result < Struct.new(:name, :context, :source_location, :failure)
      def fail?; !pass?       end
      def pass?; failure.nil? end
    end

    class Target < BasicObject

      T = ::Object.new.extend ::MiniTest::Assertions

      def initialize(value)
        @value = value
      end

      def method_missing(msg, *as, &blk)
        T.assert_send [@value, msg, *as]
      end

      undef ==
      undef !=
    end # Target
  end # Test

  RUNNER = ->(after_each, after_all, files) do
    rs = Test.execute(files).each {|r| after_each.call(r) if after_each}
    after_all.call(rs) if after_all
    rs
  end.curry

  DEFAULT_RUNNER = RUNNER.call(
    ->(r) { print r.pass? ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m" },
    ->(rs) do
      puts
      rs.select(&:fail?).each_with_index do |f,i|
        puts "#{i}:  #{f.name ? "`#{f.name}'" : "an anonymous test"} at #{f.source_location*?:}"
        puts "    #{f.failure.class}:#{f.failure.message}"
        unless f.failure.is_a? MiniTest::Assertion
          puts f.failure.backtrace.map {|b| "      #{b}"}.join(?\n)
        end
      end
      puts "#{rs.size} tests, #{rs.select(&:fail?).size} failures."
    end
  )

  def self.run(*files)
    DEFAULT_RUNNER.call(files.flatten)
  end
end # Lax


