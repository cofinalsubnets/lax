require 'lax/version'
module Lax
  autoload :Group, 'lax/group'
  autoload :Task,  'lax/task'
  autoload :Hook,  'lax/hook'
  def self.test(hooks={},&b)
    Group.define hooks, b
  end
end

