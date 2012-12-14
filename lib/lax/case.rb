module Lax
  class Case < Hash
    def test
      Lax.call self[:before], self
      self[:pass] = begin
        self[:cond][self[:value]=self[:obj].__send__(self[:msg],*self[:args],&self[:blk])]
      rescue self[:xptn] => e
        true
      rescue => e
        self[:xptn] = e
        false
      end
      Lax.call self[:after], self
    end
  end
end

