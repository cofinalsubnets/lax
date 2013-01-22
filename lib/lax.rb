class Lax
  VERSION = '0.2.4'
  TESTS   = []
  attr_reader :pass, :exception, :source

  class << self
    def scope(&b)
      Class.new(self, &b)
    end

    def let(name, &defn)
      if name.is_a? Hash
        name.each {|k,v| let(k) {v}}
      else
        define_singleton_method(name, defn)
        define_method(name) do
          @__memo__.has_key?(name)? @__memo__[name] : @__memo__[name] = defn.call
        end
      end
    end

    def before(&bef)
      mtd = instance_method :before
      define_method :before do
        mtd.bind(self).call
        instance_exec &bef
      end
    end

    def after(&aft)
      mtd = instance_method :after
      define_method :after do
        instance_exec &aft
        mtd.bind(self).call
      end
    end

    def condition(name, &cond)
      define_singleton_method(name) do |*as,&blk|
        new(blk.source_location) {cond.call *as, instance_eval(&blk)}
      end
    end

    def load(files)
      [*files].each do |file|
        File.open file, 'r' do |f|
          scope { class_eval f.read, file }
        end
      end
      self
    end

    def run
      TESTS.each &:run
    end

    def fix(hash)
      Struct.new(*hash.keys).new(*hash.values)
    end
    alias condition_group define_singleton_method
  end

  def fix(hash)
    Lax.fix hash
  end

  condition(:assert) {|n|  n}
  condition(:refute) {|n| !n}

  def before; end
  def after;  end

  def initialize(source, &test)
    @test, @__memo__, @source = test, {}, source
    TESTS << self
  end

  def run
    before
    @pass = instance_eval &@test
  rescue => e
    @exception = e
  ensure
    after
  end

  module RakeTask
    def self.new(opts = {})
      require 'rake'
      extend Rake::DSL
      o = {dir: :test, name: :lax}.merge(opts)
      task o[:name] do
        Lax.after {Output.dots self}
        Output.summarize Lax.load(Dir["./#{o[:dir]}/**/*.rb"]).run
      end
    end
  end

  module Output
    def self.dots(c)
      print c.pass ? "\x1b[32m.\x1b[0m" : "\x1b[31mX\x1b[0m"
    end

    def self.summarize(cs)
      puts
      cs.reject(&:pass).each do |f|
        puts "  failure at #{f.source*?:}"
        puts "    raised #{f.exception.class} : #{f.exception.message}" if f.exception
      end
      puts "pass: #{cs.select(&:pass).size}\nfail: #{cs.reject(&:pass).size}"
    end
  end
end

