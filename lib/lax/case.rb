module Lax
  class Case < Struct.new :subject, :condition, :exception, :source
    attr_reader :value, :pass
    def test
      begin
        @value = subject.call
      rescue exception => e
        @pass = true
        return self
      rescue => e
        @pass = false
        self.exception = e
        return self
      end
      @pass = condition.call @value
      self
    end
  end
end

