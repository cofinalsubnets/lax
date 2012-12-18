module Lax
  module Config
    # A hash for storing and accessing configuration options.
    class ConfigHash < Hash
      def method_missing(sym,arg=nil)
        sym.match(/^(.+)=$/) ? self[$1.to_sym]=arg : self[sym]
      end

      def initialize
        super {|h,k| h[k]=self.class.new}
      end

      def merge!(h)
        super {|k,o,n| Hash===o && Hash===n ? o.merge!(n) : n}
      end

      def self.from(h)
        new.merge(h).tap do |hash|
          hash.each {|k,v| hash[k]=from(v) if Hash===v}
        end
      end
    end
  end
end

