module Lax
  class Test
    module Fixtures
      def fix(hash)
        Struct.new(*hash.keys).new(*hash.values)
      end
    end

    include Fixtures
    extend  Fixtures
  end
end

