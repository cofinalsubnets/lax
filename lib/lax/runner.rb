module Lax
  def self.lazy_execute(files)
    Enumerator.new do |yielder|
      reader, results = reader(files), []
      while reader.alive?
        if (r=reader.resume).is_a?(Test::Result)
          yielder << r
          results << r
        end
      end
      results
    end
  end

  def self.reader(files)
    Fiber.new do
      files.each do |file|
        Test.group do
          instance_eval File.read(file), File.expand_path(file)
        end
      end
    end
  end

  def self.run(files, after_all=Out[:summary], after_each=Out[:dots])
    RUNNER.call after_each, after_all, files
  end

  RUNNER = ->(after_each, after_all, files) do
    rs = lazy_execute(files).each {|r| after_each.call(r) if after_each}
    after_all.call(rs) if after_all
    rs
  end.curry
end

