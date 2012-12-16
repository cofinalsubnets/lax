require 'lax/version'
module Lax
  autoload :Group, 'lax/group'
  autoload :Tree,  'lax/tree'
  autoload :Case,  'lax/case'
  autoload :Task,  'lax/task'
  autoload :Hook,  'lax/hook'
  autoload :Runner, 'lax/runner'

  class << self; attr_accessor :groups end
  self.groups = []

  def self.test(hooks={},&b)
    Group.define hooks, b
  end
end

