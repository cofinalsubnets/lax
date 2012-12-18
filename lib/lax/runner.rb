module Lax
  # Interface to an execution manager for test groups.Delegates to a
  # specialized instance, depending on initialization options.
  module Runner
    autoload :Threaded, 'lax/runner/threaded'
    autoload :Simple,   'lax/runner/simple'
    include Hook::Run
    attr_reader :hooks
    # Takes an array of uninitialized test groups and an optional parameter
    # hash. Recognized parameters are :start, :finish, :before, :after
    # (hooks) and :threads (the maximum number of threads in which test
    # groups will be executed - default 0). The value of :threads determines
    # whether execution is delegated to an instance of Runner::Simple or
    # Runner::Threaded; see their respective documentation for more details.
    def self.new(groups=Lax::Group::DEFS, opts={})
      opts = Lax.defaults :runner, opts
      (opts[:threads] > 0 ? Threaded : Simple).new groups, opts
    end

    def initialize(groups, opts)
      @groups, @threads, @hooks = groups, opts.delete(:threads), opts
    end

    # Returns a new Runner instance with fresh groups.
    def new
      Runner.new(@groups, @hooks.merge(threads: @threads))
    end

  end
end

