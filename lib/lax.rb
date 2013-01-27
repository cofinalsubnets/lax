require 'lax/version'
class Lax
  autoload :Runner,        'lax/runner'
  autoload :Assertion,     'lax/assertion'
  autoload :Output,        'lax/output'
  autoload :RakeTask,      'lax/rake_task'
  autoload :Fixture,       'lax/fixture'
  autoload :Configuration, 'lax/configuration'

  attr_reader :context, :runner

  def initialize(runner_opts={})
    @runner  = Runner.new runner_opts
    @context = Assertion.scope
  end

  def configure(&conf)
    Configuration.new(&conf).apply self
  end

  def load(*files)
    files.flatten.each do |file|
      File.open file, 'r' do |f|
        @context.scope { class_eval f.read, file }
      end
    end
  end

  def run
    @runner.run assertions
  end

  def assertions
    @context.select &:concrete?
  end

  def self.instance
    @instance ||= new
  end

  %w(run configure load context runner assertions).each do |m|
    define_singleton_method(m) do |*as,&blk|
      instance.send m, *as, &blk
    end
  end
end

