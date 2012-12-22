module Lax
  module Fixture
    def self.new(hash)
      klass = Struct.new(*hash.keys)
      klass.send :include, self
      klass.new *hash.values
    end

    module Hashable
      def self.new(hashable)
        hash = hashable.to_hash
        klass = Struct.new(*hash.keys)
        klass.send :include, self, Fixture
        klass.new(*hash.values.map do |val|
          (Hash===val) ? new(val) : val
        end)
      end

      def to_hash
        Hash[
          members.zip entries.map {|e| e.kind_of?(Hashable) ? e.to_hash : e }
        ]
      end

      def merge(hashable)
        Hashable.new to_hash.merge hashable
      end
    end
  end

  module Config
    def self.new(hash)
      Fixture::Hashable.new(hash)
    end
  end
end

