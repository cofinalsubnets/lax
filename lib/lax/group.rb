module Lax
  # Superclass for test groups. Group should never be instantiated or
  # subclassed directly; instead use Lax::test.
  class Group
    autoload :Node,     'lax/group/node'
    autoload :TestCase, 'lax/group/test_case'
    include Hook::Run
    DEFS = []
    attr_reader :hooks

    # Define a test group. Takes a hash of hooks and a proc, and generates a
    # new class encapsulating the specified tests and hooks. Lax::test is the
    # intended interface to this method.
    def self.define(hooks, spec)
      root  = Node::Root.define &spec
      group = Class.new(self) do
        define_method(:initialize) do |hs={}|
          @hooks = hooks.merge(hs)
          root.new.test_cases.map do |tc|
            name = "#{tc.name || "test_#{singleton_methods.size+1}"}"
            define_singleton_method(name) {tc.rebuild}
          end
        end
      end
      (DEFS << group).last
    end

    def test_cases
      singleton_methods.map {|tc| send tc}
    end

    def pass?
      execute.all? &:pass
    end

    def execute
      test_cases.map &:execute
    end

  end
end

