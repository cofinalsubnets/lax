module Stilts
  class Group < Array
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

    def with_block(blk,&b)
      where({blk: blk},&b)
    end

    def satisfies(cond=nil,&b)
      cond ? where({cond: cond},&b) : where(cond: b)
    end

    def raises(xptn=StandardError,&b)
      where({xptn: xptn},&b)
    end

    def returns(v,&b)
      satisfies ->(e){e==v}, &b
    end

    def where(h)
      g=Group.new tc.merge h
      yield g if block_given?
      push(g).last
    end

    def cases
      any?? map {|n| n.any? ? n.cases : n.tc}.flatten : [tc]
    end
  end
end

