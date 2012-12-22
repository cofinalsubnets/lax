module Lax
  module Tree
    include Enumerable
    def each(&b)
      yield self
      children.each {|c| c.each(&b) if c.kind_of? Tree}
    end

    def root
      parent ? parent.root : self
    end
  end
end

