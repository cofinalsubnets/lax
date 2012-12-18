module Lax
  class Group
    class Node
      module Navigation
        def address
          parent ? parent.address.push(local_index) : []
        end

        def root
          parent ? parent.root : self
        end

        def visit(*loc)
          loc.reduce(self, :[])
        end

        def local_index
          parent.index {|n| n.equal? self}
        end
      end
    end
  end
end

