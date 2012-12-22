module Lax
  # Proc with methods for composing and appending instances, and a facility
  # dynamically defining and retrieving callbacks.
  class Hook < Proc

    module Util
      class << self
        def compose(p1,p2)
          Hook.new {|*a,&b|p1.call p2.call(*a,&b)}
        end

        def append(p1,p2)
          Hook.new {|*a,&b| p1.call *a,&b;p2.call *a,&b}
        end

        def conjoin(p1,p2)
          Hook.new {|*a,&b| p1.call(*a,&b) and p2.call(*a,&b)}
        end
      end
    end

    class << self
      def _resolve(hook)
        if hook.is_a? Hook
          hook
        elsif hook.is_a? Proc
          new &hook
        elsif hook.is_a?(Symbol) and self.respond_to?(hook)
          send hook
        else
          raise ArgumentError, "Unable to resolve hook `#{hook}'"
        end
      end

      # Returns a hook implementing the identity function.
      def id
        new {|i|i}
      end

      def noop
        new {|*a|}
      end

      def output
        new {|tc| print tc.pass? ? "\x1b[32m-\x1b[0m" : "\x1b[31mX\x1b[0m"}
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

      # Define a named hook.
      # Takes a symbol and a block; the symbol then names a class method on
      # Hook that returns a new instance generated from the supplied block.
      # The symbol can then be used as an argument to Hook#<< and Hook#+
      def define(sym, &p)
        define_singleton_method(sym) {new &p}
      end
    end

    # Composition. hook can be a Proc (or similar) or a symbol naming a
    # defined hook (i.e. a class method on Hook that returns a Hook).
    def <<(hook)
      Hook::Util.compose self, Hook._resolve(hook)
    end

    # Returns a new hook that takes arbitrary parameters, then calls the
    # receiver and the argument sequentially with those parameters. As with
    # #<<, the argument can be a Proc or a symbol.
    def +(hook)
      Hook::Util.append self, Hook._resolve(hook)
    end

    def &(hook)
      Hook::Util.conjoin self, Hook._resolve(hook)
    end
  end
end

