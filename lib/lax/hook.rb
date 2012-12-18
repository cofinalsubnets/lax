module Lax
  # Proc with methods for composing and appending instances, and a facility
  # dynamically defining and retrieving callbacks.
  class Hook < Proc
    def self.compose(p1,p2)
      Hook.new {|*a,&b|p1.call p2.call(*a,&b)}
    end

    def self.append(p1,p2)
      Hook.new {|*a,&b| p1.call *a,&b;p2.call *a,&b}
    end

    def self.conjoin(p1,p2)
      Hook.new {|*a,&b| p1.call(*a,&b) and p2.call(*a,&b)}
    end

    # Convenience methods for classes the implement hooks.
    module Run
      def method_missing(sym, *a, &b)
        hooks.has_key?(sym)? run_hook(sym, *a, &b) : super
      end

      private
      def around_hook(init=nil, h1=:before, h2=:after)
        run_hook h1, init
        yield.tap{|v|run_hook h2,v}
      end

      def run_hook(h,*a,&b)
        resolve_hook(hooks[h]).call(*a,&b) if hooks.has_key?(h)
      end

      def resolve_hook(hook)
        Symbol===hook ? Hook.send(hook) : hook
      end
    end

    include Run
    class << self
      # Returns a hook implementing the identity function.
      def id
        new {|i|i}
      end

      def output
        new {|tc| print tc.pass ? "\x1b[32m-\x1b[0m" : "\x1b[31mX\x1b[0m"}
      end

      # Returns a hook for generating terminal output from test cases.
      def summary
        new {|cs| puts "\nFinished #{cs.size} tests with #{cs.reject(&:pass).size} failures"}
      end

      # Returns a hook for generating terminal output from test cases.
      def failures
        new {|cs| cs.reject(&:pass).each {|f| puts "  #{f.subject.source_location*?:}"}}
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
      Hook.compose self, resolve_hook(hook)
    end

    # Returns a new hook that takes arbitrary parameters, then calls the
    # receiver and the argument sequentially with those parameters. As with
    # #<<, the argument can be a Proc or a symbol.
    def +(hook)
      Hook.append self, resolve_hook(hook)
    end

    def &(hook)
      Hook.conjoin self, resolve_hook(hook)
    end
  end
end

