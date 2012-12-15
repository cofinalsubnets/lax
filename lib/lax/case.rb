module Lax
  class Case < Struct.new :subject, :condition, :exception, :source
    attr_reader :value, :pass
    def test
      begin
        @value = subject.call
      rescue exception => e
        return @pass = true
      rescue => e
        @pass = false
        return self.exception = e
      end
      @pass = condition.call @value
    end
  end
end

