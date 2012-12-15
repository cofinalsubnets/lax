module Lax
  class Group < Array
    def self.inherited(klass)
      Lax.groups << klass
    end

    def initialize(subj=proc{}, cond=proc{|e|e}, xptn=nil, src=nil)
      @subj, @cond, @xptn, @src = subj, cond, xptn, src
    end

    def subject(src=caller.first, &b)
      push(self.class.new Proc.new(&b), @cond, @xptn, src).last
    end

    def condition(src=caller.first, &b)
      push(self.class.new @subj, preproc(b), @xptn, src).last
    end

    def raises(xptn=StandardError, src=caller.first)
      push(self.class.new @subj, @cond, xptn, src).last
    end

    def _(tree,&b)
      tree.instance_exec &b
    end

    def its(&b)
      subject(caller.first) { @subj.call.instance_eval &b }
    end

    def it(t=nil, &b)
      b ? _condition(&b) : self
    end

    def on(*subs, &b)
      b ? subject(caller.first, &b) : subs.each {|s| subject(caller[2]) {s}}
    end

    def !
      _condition {|e| not cond[e]}
    end

    def equals(o=nil,&b)
      self == (b ? b.call : o)
    end

    alias s subject
    alias c condition
    alias x raises
    alias satisfies condition
    alias let _

    def leaves
      any?? map(&:leaves).flatten : [Case.new(@subj, @cond, @xptn, @src)]
    end

    def preproc(b)
      b.parameters.any?? b : ->(e) {e.instance_exec &b}
    end

    def _condition(&b)
      condition caller[1], &b
    end

    %w{== === != =~ > < >= <=}.each do |m|
      eval "def #{m} o;_condition{|r|r#{m}o} end"
    end
    private :preproc, :_condition
  end
end

