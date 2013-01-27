class Lax
  class Runner
    attr_accessor :threads, :start, :finish, :before, :after
    DEFAULTS = { threads: 1 }

    def initialize(opts={})
      DEFAULTS.merge(opts).each {|k,v| send "#{k}=", v}
    end

    def run(assertions)
      run_callback :finish, run_threaded(run_callback :start, assertions)
    end

    private
    def run_threaded(assertions)
      queue, mutex = assertions.each, Mutex.new
      threads.times.map {runner_thread queue, mutex}.flat_map &:value
    end

    def runner_thread(queue, mutex)
      Thread.new do
        assertions = []
        while (assertion = mutex.synchronize { queue.next rescue() })
          assertions << run_test(assertion)
        end
        assertions
      end
    end

    def run_test(assertion)
      run_callback :after, run_callback(:before, assertion).new
    end

    def run_callback(cb, target)
      send(cb).call(target) if send(cb)
      target
    end
  end
end

