module Lax
  class Tree
    include Enumerable
    attr_reader :parent, :children
    def initialize(parent=nil)
      unless parent.is_a?(Tree) or parent.nil?
        raise(TypeError, "Can't initialize node with parent #{parent}") 
      end
      @parent, @children = parent, []
    end

    def each(&b)
      yield self
      children.each {|c| c.each(&b) if c.kind_of? Tree}
    end

    def root
      parent ? parent.root : self
    end
  end
end

