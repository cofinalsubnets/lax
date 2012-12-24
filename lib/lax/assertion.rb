class Lax
  class Assertion < Struct.new(:target, :subject, :condition, :src, :call_chain, :matcher, :args, :doc)
    module Xptn; end

    def pass?
      memoize(:pass) { condition.call value }
    end

    def value
      memoize(:value) { resolve_call_chain }
    end

    def validate
      memoize(:validate) do
        begin
          tap {pass?}
        rescue => e
          Exception.new(e, *self)
        end
      end
    end

    def show
      [target, *call_chain.map {|c| call_to_s *c}, call_to_s(matcher, args, nil)].join ?.
    end

    private
    def resolve_call_chain
      call_chain.reduce(subject.call) {|v,c| v.__send__ c[0],*c[1],&c[2]}
    end

    def memoize(key)
      (@memo||={}).has_key?(key) ? @memo[key] : @memo[key] = yield
    end

    def call_to_s(m,a,b)
      "#{m}#{"(#{a.map(&:inspect).join ', '})" if !a.empty?}#{" {...}" if b}"
    end

    class Exception < Assertion
      include Xptn
      attr_reader :exception
      def pass?; nil end
      def value; nil end
      def initialize(x, *as)
        super(*as)
        @exception = x
      end

      class Toplevel < Struct.new :doc, :exception
        include Xptn
        def validate; self end
        def pass?;    nil  end
        def show;          end
        def src
          exception.backtrace.first
        end
      end

    end
  end
end

