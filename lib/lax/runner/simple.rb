module Lax
  module Runner
    # Runner for single-threaded deterministic execution of tests. Initialized
    # by Runner::new if the :threads parameter is less than or equal to zero
    # (which is the default value). Should never be instantiated directly;
    # use Runner::new instead.
    class Simple
      include Runner
      def run
        around_hook(@groups, :start, :finish) do
          @groups.map do |group|
            around_hook(g=group.new) {g.execute}
          end.flatten
        end
      end
    end
  end
end

