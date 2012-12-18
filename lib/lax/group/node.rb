module Lax
  class Group
    class Node < Array
      require_relative 'node/navigation'
      require_relative 'node/dsl'
      require_relative 'node/execution'
      require_relative 'node/root'
      include DSL
      attr_reader :parent, :spec

      def initialize(parent, spec)
        @parent, @spec = parent, spec
      end

      def walk(&blk)
        blk.call(self) if !parent
        each do |node|
          blk.call node
          node.walk(&blk)
        end
      end

      private
      def append_node(opts)
        push(Node.new self, spec.merge(opts)).last
      end
    end
  end
end

