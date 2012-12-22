class Lax
  module DSL
    def let(h)
      h.each do |key, value|
        instance_variable_set "@#{key}", value
      end
      self
    end

    def fix(hash)
      Fixture.new hash
    end


    def assert(*vals, &b)
      Class.new(self).tap {|c| c.class_eval &b }
    end
  end
end

