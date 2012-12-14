require 'rake'
module Lax
  module Task
    class << self
      include Rake::DSL
      def new(opts = {})
        dir = opts.delete(:dir) || :test
        make_tasks dir, {
          start:  Hook::StartTime,
          after:  Hook::PassFail,
          finish: Hook::StopTime + Hook::Summary + Hook::Failures
        }.merge(opts)
      end

      private
      def make_tasks(dir, opts)
        namespace dir do
          desc "[Lax] load all test files"
          task load: make_groups(dir)
          desc "[Lax] run all loaded tests"
          task(:run) { Lax.test! Lax.cases, opts }
        end
        desc "[Lax] load and run all tests"
        task dir => ["#{dir}:load","#{dir}:run"]
      end

      def make_groups(dir)
        FileList["#{dir}/**/*"].select {|f| File.directory? f}.map do |group|
          name = group.sub(/^#{dir}\//,'').gsub(/\//,?:)
          desc "[Lax] load files in #{group}"
          task(name) { Dir["#{group}/*.rb"].each {|file| load file} }
        end
      end
    end
  end
end

