module Lax
  class Test

    def self.before(&bef)
      mtd = instance_method(:__before__)
      define_method :__before__ do
        mtd.bind(self).call
        instance_exec(&bef)
      end
    end

    def self.after(&aft)
      mtd = instance_method(:__after__)
      define_method :__after__ do
        instance_exec(&aft)
        mtd.bind(self).call
      end
    end

    private 

    def __before__
    end

    def __after__
    end

  end
end

