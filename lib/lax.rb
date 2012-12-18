require 'lax/version'
require 'lax/config'
module Lax
  include Config
  autoload :Group,    'lax/group'
  autoload :Hook,     'lax/hook'
  autoload :RakeTask, 'lax/rake_task'
  autoload :Runner,   'lax/runner'

  config(
    task: { dir: :test },
    test_case: {
      after: Hook.output
    },
    runner: {
      threads: 0,
      finish: Hook.summary + Hook.failures,
    }
  )

  # Start a test block. Accepts an optional hash of default hooks. See
  # TestGroup::define for more information.
  def self.test(hooks={}, &b)
    Group.define defaults(:group, hooks), b
  end

  # Define a matcher. Takes a symbol and an optional block. See
  # TestGroup::define_matcher for more information.
  def self.matcher(sym, &b)
    Group::Node::DSL.define_matcher sym, &b
  end

  # Define a hook. Takes a symbol and a block. See Hook::define for more
  # information.
  def self.hook(sym, &b)
    Hook.define sym, &b
  end
end

