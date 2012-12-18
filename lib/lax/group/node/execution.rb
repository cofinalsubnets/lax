module Lax
  class Group
    class Node
      module Execution
        def test_case
          TestCase.new self
        end

        def test_cases
          [].tap do |cs|
            walk do |node|
              cs << node.test_case if node.empty?
            end
          end
        end
      end
    end
  end
end

