module Lax
  class Group
    class TestCase
      include Hook::Run
      attr_reader :value, :pass, :exception, :node, :hooks

      def initialize(node)
        @node = node
        @hooks = Lax.defaults :test_case, node.spec[:hooks]
      end

      def subject;   node.spec[:subject]   end
      def condition; node.spec[:condition] end
      def address;   node.address          end

      def name
        node.spec[:name]
      end

      def rebuild
        node.root.rebuild.visit(*address).test_case
      end

      def execute
        around_hook(self) do
          begin
            @value = subject.call
          rescue => e
            @exception, @pass = e, (condition===e)
          else
            @pass = condition.call(@value)
          end
          self
        end
      end

    end
  end
end

