module Lax
  # Configuration module for Lax.
  module Config
    require 'lax/config/config_hash'
    def self.included(klass)
      klass.extend ClassMethods
      klass.const_set :CONFIG, ConfigHash.new
    end

    module ClassMethods
      # Accessor for the config hash.
      def config(h=nil)
        h ? self::CONFIG.merge!(ConfigHash.from h) : self::CONFIG
      end

      def defaults(key, h)
        self::CONFIG[key].dup.merge!(h)
      end
    end
  end
end

