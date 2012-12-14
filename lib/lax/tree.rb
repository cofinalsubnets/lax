module Lax
  class Tree < Array
    attr_reader :tc
    def initialize(tc={})
      @tc=tc
    end

    def on(obj,&b)
      where({obj: obj},&b)
    end

    def calling(msg,&b)
      where({msg: msg},&b)
    end

    def with(*args,&b)
      where({args: args},&b)
    end

    def with_block(blk=nil,&b)
      blk  ? where({blk: blk},&b)   : where(blk: b)
    end

    def satisfies(cond=nil,&b)
      cond ? where({cond: cond},&b) : where(cond: preproc(b))
    end

    def before(bef=nil,&b)
      bef ? where({before: bef},&b) : where(before: b)
    end

    def after(aft=nil,&b)
      aft ? where({after: aft},&b)  : where(after: b)
    end

    def raises(xptn=StandardError,&b)
      where({xptn: xptn},&b)
    end

    def it(&b)
      calling(:tap).with_block proc {}, &b
    end

    def returns(v,&b)
      satisfies ->(e){e==v}, &b
    end

    def where(h,&b)
      t=Tree.new tc.merge h 
      preproc(b)[t] if b
      push(t).last
    end

    def leaves
      any?? map(&:leaves).flatten : [tc]
    end

    private
    def preproc(p)
      p.parameters.any?? p : ->(o) { o.instance_exec &p }
    end
  end
end

