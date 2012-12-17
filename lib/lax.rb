require 'lax/version'
module Lax
  autoload :Group,  'lax/group'
  autoload :Hook,   'lax/hook'
  autoload :Task,   'lax/task'
  autoload :Config, 'lax/config'
  extend Config
  def self.test(hooks={},&b)
    Group.define hooks, b
  end

  def self.matcher(sym,&b)
    Group::Node.define_matcher sym, &b
  end

  def self.hook(sym, &b)
    Hook.define sym, &b
  end
end

