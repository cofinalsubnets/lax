module Lax
  class Case < Hash
    def test
      self[:before][self] if self[:before]
      self[:pass] = begin
        self[:cond][self[:value]=self[:obj].__send__(self[:msg],*self[:args],&self[:blk])]
      rescue self[:xptn] => e
        true
      rescue => e
        self[:xptn] = e
        false
      end
      self[:after][self] if self[:after]
    end
  end
end

