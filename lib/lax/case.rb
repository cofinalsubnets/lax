module Lax
  class Case < Hash
    def run
      self[:before] and self[:before][self]
      self[:pass] = begin
        self[:cond][self[:value]=self[:obj].__send__(self[:msg],*self[:args],&self[:blk])]
      rescue self[:xptn] => e
        true
      rescue => e
        self[:xptn] = e
        false
      end
      self[:after] and self[:after][self]
    end
  end
end
