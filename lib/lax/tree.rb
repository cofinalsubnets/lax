module Lax
  class Tree < Array
    %w{== === != =~ > < >= <=}.each do |m|
      define_method(m) {|o|_c{|r|r.__send__ m,o}}
    end

    def initialize(subj=proc{}, cond=proc{|e|e}, xptn=nil, src=nil)
      @subj, @cond, @xptn, @src = subj, cond, xptn, src
    end

    def s(src=caller.first, &b)
      push(Tree.new Proc.new(&b), @cond, @xptn, src).last
    end

    def c(src=caller.first, &b)
      push(Tree.new @subj, preproc(b), @xptn, src).last
    end

    def x(xptn=StandardError, src=caller.first)
      push(Tree.new @subj, @cond, xptn, src).last
    end

    def _(tree,&b)
      tree.instance_exec &b
    end

    def its(&b)
      _s { @subj.call.instance_exec &b }
    end

    def it(t=nil, &b)
      b ? _c(&b) : self
    end

    def on(*subs, &b)
      b ? _s(&b) : subs.each {|s| s(caller[2]) {s}}
    end

    def eq(o=nil,&b)
      self == (b ? b.call : o)
    end

    def leaves
      any?? map(&:leaves).flatten : [Case.new(@subj, @cond, @xptn, @src)]
    end

    private
    def preproc(b)
      b.parameters.any?? b : ->(e) {e.instance_exec &b}
    end
    def _s(&b); s caller[1], &b end
    def _c(&b); c caller[1], &b end
  end
end

