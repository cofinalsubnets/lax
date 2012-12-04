module Lax
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

