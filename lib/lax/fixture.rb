class Lax
  module Fixture
    def self.new(hash)
      Struct.new(*hash.keys).new(*hash.values)
    end

    def fix(hash)
      Fixture.new hash
    end
  end
end

