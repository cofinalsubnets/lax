module Lax
  class Test

    class Result < Struct.new(:name, :context, :source_location, :failure)
      def fail?
        !pass?
      end
    end

    class Fail < Result
      def pass?
        false
      end
    end

    class Pass < Result
      def pass?
        true
      end
    end

  end
end

