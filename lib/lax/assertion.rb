module Lax
  class Assertion < Struct.new :name, :subject, :condition, :src, :matcher, :args, :hooks
    autoload :Node,  'lax/assertion/node'
    autoload :Root, 'lax/assertion/root'
    autoload :Subject, 'lax/assertion/subject'

    def pass?
      memoize(:pass) { condition.call value }
    end

    def value
      memoize(:value) { subject.call }
    end

    def validate
      memoize(:validate) do
        hooks.before.call self
        pass?
        self.tap { hooks.after.call self }
      end
    end

    private
    def memoize(key)
      @memo ||= {}
      @memo.has_key?(key) ? @memo[key] : @memo[key] = yield
    end

  end
end

