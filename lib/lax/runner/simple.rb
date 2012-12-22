class Lax
  module Runner
    # Runner for single-threaded deterministic execution of tests. Initialized
    # by Runner::new if the :threads parameter is less than or equal to zero
    # (which is the default value). Should never be instantiated directly;
    # use Runner::new instead.
    class Simple
      include Runner
      def run
        assertions = Lax.flat_map {|l| l.new.assertions}
        hooks.before.call assertions
        hooks.after.call  assertions.map(&:validate)
      end
    end
  end
end

