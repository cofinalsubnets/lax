module Stilts
  class RakeTask
    include Rake::DSL
    def initialize(runner_opts = {})
      runner_opts = {
          before: Runner::Callback::StartTime,
          after:  Runner::Callback::StopTime + Runner::Callback::SimpleOut,
          finish: Runner::Callback::Summary + Runner::Callback::FailList
      }.merge runner_opts
      make_tasks runner_opts
    end

    private
    def make_tasks(runner_opts)
      namespace :test do
        desc "[Stilts] load all test files"
        task load: make_test_groups
        desc "[Stilts] run all loaded tests"
        task(:run) { Stilts.go! runner_opts }
      end
      desc "[Stilts] load and run all tests"
      task test: %w{test:load test:run}
    end

    def make_test_groups
      tests  = []
      groups = FileList["test/**/*"].select {|f| File.directory? f}
      groups.each do |group|
        tests << name = group.gsub(/\//,?:)
        desc "[Stilts] load files in #{group}"
        task name.sub(/^test:/,'') do
          Dir["#{group}/*.rb"].each {|file| load file }
        end
      end
      tests
    end

  end
end

