class Lax
  module Run

    def go!
      instance = new
      assertions.map {|a| new.send a}.map &:validate
    end

  end
end

