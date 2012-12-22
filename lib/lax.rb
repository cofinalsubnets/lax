require 'lax/version'
module Lax
  autoload :Fixture, 'lax/config'
  autoload :Assertion, 'lax/assertion'
  autoload :Tree, 'lax/tree'
  autoload :Hook, 'lax/hook'
  autoload :RakeTask, 'lax/rake_task'
  autoload :Runner,   'lax/runner'
  autoload :CattrAssertable, 'lax/cattr_assertable'



  CONFIG = Fixture::Hashable.new(
    task: { dir: :test },
    assertion: {
      hooks: {
        before: Hook.noop,
        after: Hook.output
      }
    },
    runner: {
      threads: 0,
      hooks: { 
        before: Hook.noop,
        after:  Hook.summary
      }
    }
  )

  def self.config
    CONFIG
  end

  def self.configure
    yield config
  end

  def self.assert(&spec)
    Assertion::Node.assert &spec
  end

  def self.define_matcher(sym, &b)
    Assertion::Subject.define_matcher sym, &b
  end

  def self.define_hook(sym, &b)
    Hook.define sym, &b
  end

  def self.register(group)
    assertion_groups << group
    group
  end

  def self.assertion_groups
    ASSERTION_GROUPS
  end
end

