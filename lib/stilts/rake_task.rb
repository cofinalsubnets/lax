module Stilts
  class RakeTask
    include Rake::DSL
    def initialize(opts = {})
      dir = opts.delete(:dir) || :test
      runner_opts = {
          start:  CB::StartTime,
          after:  CB::SimpleOut,
          finish: CB::StopTime + CB::Summary  + CB::FailList
      }.merge opts
      make_tasks dir, runner_opts
    end

    private
    def make_tasks(dir, runner_opts)
      namespace dir do
        desc "[Stilts] load all test files"
        task load: make_test_groups(dir)
        desc "[Stilts] run all loaded tests"
        task(:run) { Stilts.go runner_opts }
      end
      desc "[Stilts] load and run all tests"
      task dir => ["#{dir}:load","#{dir}:run"]
    end

    def make_test_groups(dir)
      FileList["#{dir}/**/*"].select {|f| File.directory? f}.map do |group|
        name = group.sub(/^#{dir}\//,'').gsub(/\//,?:)
        desc "[Stilts] load files in #{group}"
        task name do
          Dir["#{group}/*.rb"].each {|file| load file }
        end
        "#{dir}:#{name}"
      end
    end
  end
end

