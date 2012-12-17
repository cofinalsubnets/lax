module Lax
  class Group
    class Case < Struct.new :subject, :condition
      attr_reader :value, :pass, :exception
      def src; subject.source_location end
      def test
        begin
          @value = subject.call
        rescue => e
          @exception, @pass = e, (condition===e)
        else
          @pass = condition[@value]
        end
        self
      end
    end
  end
end

