module Lax
  module Runner
    # Runner for single-threaded deterministic execution of tests. Initialized
    # by Runner::new if the :threads parameter is less than or equal to zero
    # (which is the default value). Should never be instantiated directly;
    # use Runner::new instead.
    class Simple
      include Runner
      def run
        hooks.before.call self
        hooks.after.call(@groups.flat_map do |group|
          group.new.flat_map do |node|
            node.assertions.map &:validate
          end
        end)
      end
    end
  end
end

