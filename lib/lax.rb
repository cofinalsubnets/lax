require 'lax/version'
module Lax
  class << self
    @@cases = []
    def test(c={},&b)
      @@cases += Tree.new(c).tap(&b).leaves
    end

    def go(runner_opts={})
      Runner.new(@@cases, runner_opts).go
    end
  end

  class Case < Hash
    def run
      self[:before] and self[:before][self]
      self[:pass] = begin
        self[:cond][self[:value]=self[:obj].__send__(self[:msg],*self[:args],&self[:blk])]
      rescue self[:xptn] => e
        true
      rescue => e
        self[:xptn] = e
        false
      end
      self[:after] and self[:after][self]
    end
  end

  class Tree < Array
    attr_reader :tc
    def initialize(tc={})
      @tc = Case.new.merge tc
    end

    def on(obj,&b)
      where({obj: obj},&b)
    end

    def calling(msg,&b)
      where({msg: msg},&b)
    end

    def with(*args,&b)
      where({args: args},&b)
    end

    def with_block(blk=nil,&b)
      blk  ? where({blk: blk},&b)   : where(blk: b)
    end

    def satisfies(cond=nil,&b)
      cond ? where({cond: cond},&b) : where(cond: b)
    end

    def before(bef=nil,&b)
      bef ? where({before: bef},&b) : where(before: b)
    end

    def after(aft=nil,&b)
      aft ? where({after: aft},&b)  : where(after: b)
    end

    def raises(xptn=StandardError,&b)
      where({xptn: xptn},&b)
    end

    def it
      calling(:tap).with_block {}
    end

    def returns(v,&b)
      satisfies ->(e){e==v}, &b
    end

    def where(h)
      g=Tree.new tc.merge h 
      yield g if block_given?
      push(g).last
    end

    def leaves
      any?? map(&:leaves).flatten : [tc]
    end
  end

  # Runner for test cases. Handles callbacks, concurrency, etc.
  class Runner
    attr_reader :cases
    # Takes an array of test cases and an optional hash of options.
    def initialize(cases, opts={})
      @cases, @opts = cases, {threads: 1}.merge(opts)
    end

    def go
      @opts[:start][self] if @opts[:start]
      todo = cases.dup
      (1..@opts[:threads]).map do
        Thread.new {run todo.shift while todo.any?}
      end.each &:join
      @opts[:finish][self] if @opts[:finish]
      self
    end

    private
    def run(c)
      @opts[:before][c] if @opts[:before]
      c.run
      @opts[:after][c] if @opts[:after]
    end
  end

  class Hook < Proc
    def <<(cb); Hook.new {|e| self[cb[e]]}    end
    def +(cb);  Hook.new {|e| self[e]; cb[e]} end

    StartTime = Hook.new do |rn|
      rn.extend(Module.new {attr_accessor :start, :stop}).start = Time.now
    end

    StopTime  = Hook.new {|rn| rn.stop = Time.now }

    SimpleOut = Hook.new {|tc| $stdout.write(tc[:pass] ? "\x1b[32m=\x1b[0m" : "\x1b[31m#\x1b[0m")}

    Summary   = Hook.new do |rn|
      puts "\nFinished #{(cs=rn.cases).size} tests" <<
        " in #{(rn.stop - rn.start).round 10} seconds" <<
        " with #{(cs.reject{|c|c[:pass]}).size} failures"
    end

    FailList  = Hook.new do |rn|
      rn.cases.reject {|c|c[:pass]}.each do |f|
        puts "  #{Module===f[:obj] ? "#{f[:obj]}::" : "#{f[:obj].class}#"}#{f[:msg]}" <<
          "#{?(+[*f[:args]]*', '+?) if f[:args]} " << (f.has_key?(:value) ? "#=> #{f[:value]}" : "raised unhandled #{f[:xptn].class}")
      end
    end
  end

  class Task
    include Rake::DSL
    def initialize(opts = {})
      dir = opts.delete(:dir) || :test
      runner_opts = {
          start:  Hook::StartTime,
          after:  Hook::SimpleOut,
          finish: Hook::StopTime + Hook::Summary + Hook::FailList
      }.merge opts
      make_tasks dir, runner_opts
    end

    private
    def make_tasks(dir, runner_opts)
      namespace dir do
        desc "[Lax] load all test files"
        task load: make_groups(dir)
        desc "[Lax] run all loaded tests"
        task(:run) { Lax.go runner_opts }
      end
      desc "[Lax] load and run all tests"
      task dir => ["#{dir}:load","#{dir}:run"]
    end

    def make_groups(dir)
      FileList["#{dir}/**/*"].select {|f| File.directory? f}.map do |group|
        name = group.sub(/^#{dir}\//,'').gsub(/\//,?:)
        desc "[Lax] load files in #{group}"
        task(name) { Dir["#{group}/*.rb"].each {|file| load file} }
        [dir,name]*?:
      end
    end
  end
end

