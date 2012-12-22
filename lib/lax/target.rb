class Lax
  class Target < BasicObject
    def self.define_matcher(sym, &p)
      define_method(sym) do |*a,&b|
        p ? 
          satisfies(sym) {|o|p[*a,&b][o]} :
          satisfies(sym,*a) {|o|o.__send__ sym,*a,&b}
      end
    end

    def self.define_predicate(sym)
      if sym =~ /(.*)(\?|_?p)$/
        define_method($1) { satisfies($1) {|o| o.__send__ sym} }
      else
        raise ArgumentError, "#{sym} does not appear to be a predicate"
      end
    end

    %w{== === != =~ > < >= <=}.each {|m| define_matcher m}
    %w{odd? even? is_a? kind_of? include?}.each {|m| define_predicate m}

    def initialize(node, subj, name, src)
      @node, @subj, @name, @src = node, subj, name, src 
    end

    def satisfies(matcher=nil, *args, &cond)
      assert!(cond, *[ matcher, args ])
    end

    def method_missing(sym, *args, &blk)
      Target.new @node, ->{@subj.call.__send__(sym, *args, &blk)}, @name, @src
    end

    private
    def assert!(cond, matcher=nil, args=nil)
      ord = @node.assertions.select {|m| m=~/^#{@name}_(\d)+$/}.size
      name, subj, src, hooks = @name, @subj, @src, @node.hooks
      @node.send(:define_method, "#{@name}_#{ord}") do
        ::Lax::Assertion.new name, subj, cond, src, matcher, args, hooks
      end
      @node.assertions <<  "#{@name}_#{ord}".to_sym
    end

  end
end

