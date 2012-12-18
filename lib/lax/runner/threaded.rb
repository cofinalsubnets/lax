module Lax
  module Runner
    # Runner for concurrent tests, capable of pausing and resuming execution.
    # Initialized by Runner::new if the :threads parameter is greater than
    # zero. Should never be instantiated directly; use Runner::new instead.
    class Threaded
      include Runner
      # Begin execution. This method is non-blocking; to wait for the tests
      # to finish and recover the results, use #finish.
      def run
        @instances, @done = @groups.map(&:new), []
        @im, @dm, @running = Mutex.new, Mutex.new, true
        run_hook :start, @instances
        @pool = (1..@threads).map {spawn_thread}
        self
      end

      def pause
        @running = false
      end

      def resume
        @running = true
        @pool.each {|t| t.run if t.alive?}
        true
      end

      # Join test threads, invoke finish hook, and return the test results.
      def finish
        resume unless @running
        @pool.each &:join
        @done.flatten.tap {|cs| run_hook :finish, cs}
      end

      private
      def spawn_thread
        Thread.new do
          while group = @im.synchronize {@instances.shift}
            Thread.stop unless @running
            done = around_hook(group) {group.execute}
            @dm.synchronize {@done.push done}
          end
        end
      end
    end

  end
end

