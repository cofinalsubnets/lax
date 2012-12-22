require 'lax/version'
class Lax
  autoload :Fixture,     'lax/fixture'
  autoload :Interaction, 'lax/interaction'
  autoload :Assertion,   'lax/assertion'
  autoload :Target,      'lax/target'
  autoload :Hook,        'lax/hook'
  autoload :RakeTask,    'lax/rake_task'
  autoload :Runner,      'lax/runner'
  autoload :DSL,         'lax/dsl'

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

  extend  Enumerable, DSL, Interaction
  class << self
    attr_accessor :children, :hooks, :assertions

    def config
      CONFIG
    end

    def configure
      yield config
    end

    def matcher(sym, &b)
      Target.define_matcher sym, &b
    end

    def hook(sym, &b)
      Hook.define sym, &b
    end

    def each(&b)
      yield self
      children.each {|c| c.each(&b)}
    end
  end

  @assertions = []
  @children   = []
  @hooks      = config.assertion.hooks

  def self.inherited(child)
    const_set("#{self==Lax ? 'Root' : 'Node'}_#{self.children.size}", child)
    @children << child
    child.children   = []
    child.assertions = []
    child.hooks      = self.hooks.dup
    defs.each do |ivar|
      child.instance_variable_set ivar, eval("#{ivar}")
    end
  end

  def self.method_missing(name, *args, &blk)
    if instance_variables.include?("@#{name}".to_sym)
      define_singleton_method(name) do
        Lax::Target.new self, ->{eval "@#{name}"}, name, nil
      end
      send name, *args, &blk
    else
      super
    end
  end

  def assertions
    self.class.assertions.map {|a| send a}
  end

  private

  def self.defs
    instance_variables - special_ivars
  end

  def self.special_ivars
    [ :@children, :@hooks, :@assertions, :@parent ]
  end
end

