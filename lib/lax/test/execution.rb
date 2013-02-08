require 'fiber'
module Lax
  class Test

    def initialize(name=nil)
      @__memo__, @__name__ = {}, name
    end

    def __execute__(test)
      args = [@__name__, self.class.name, test.source_location]
      __before__
      instance_exec(&test)
      Pass.new(*args)
    rescue Exception => e
      Fail.new(*args, e)
    ensure
      __after__
    end

  end
end

