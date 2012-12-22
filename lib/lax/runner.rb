module Lax
  # Interface to an execution manager for test groups.Delegates to a
  # specialized instance, depending on initialization options.
  module Runner
    autoload :Threaded, 'lax/runner/threaded'
    autoload :Simple,   'lax/runner/simple'
    attr_reader :hooks

    def self.new(groups=Lax::Assertion::Node.children, threads=Lax.config.runner.threads, hooks={})
      hooks = Lax.config.runner.hooks.merge hooks
      (threads > 0 ? Threaded : Simple).new groups, threads, hooks
    end

    def initialize(groups, threads, hooks)
      @groups, @threads, @hooks = groups, threads, hooks
    end

  end
end

