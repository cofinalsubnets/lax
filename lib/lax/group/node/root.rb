module Lax
  class Group
    class Node

      class Root < Node
        def self.define(&spec)
          Class.new(self) do
            define_method(:initialize) do
              @spec = {
                hooks: {},
                condition: Hook.id
              }
              instance_eval &spec
              walk {|n| n.extend Navigation, Execution}
            end
          end
        end

        def rebuild
          self.class.new
        end
      end

    end
  end
end

