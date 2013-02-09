require 'fiber'
class Lax < Module

  class Failure < StandardError; end

  class Test < Struct.new(:location, :failure)
    def pass?
      failure.nil?
    end
  end

  def self.load(files)
    root   = Fiber.current
    reader = Fiber.new { files.each {|f| new(root).load f}; nil }
    Enumerator.new {|y| while (r=reader.transfer); y<<r end }
  end

  def self.matcher(name, &matcher)
    define_method name, matcher.curry
  end

  def self.run(files)
    runner method(:dots), method(:summary), files
  end

  def self.dots(r)
    print (r.pass? ? "\x1b[32m." : "\x1b[31mX") << "\x1b[0m"
  end

  def self.summary(rs)
    puts
    rs.reject(&:pass?).each_with_index do |f,i|
      puts "#{i}:  At #{f.location*?:}\n    #{f.failure.class.name}: #{f.failure.message}"
      unless f.failure.is_a? Failure
        puts f.failure.backtrace.map {|b| "      #{b}"}.join(?\n)
      end
    end
    puts "#{rs.size} tests, #{rs.reject(&:pass?).size} failures"
  end

  def self.fail_with(str)
    raise Failure, str
  end

  define_singleton_method :runner, ->(each, all, files) do
    Lax.load(files).map {|r| each.call r if each; r}.tap {|rs| all.call(rs) if all}
  end.curry

  matcher(:truthy) {|s|   s    or Lax.fail_with "Expected #{s.inspect} to be a true value"}
  matcher(:equals) {|o,s| s==o or Lax.fail_with "Expected #{o.inspect}; got #{s.inspect}\n(using ==)"}
  matcher :returns do |exp, mtd, args, blk, s|
    s.__send__(mtd, *args, &blk) == exp or
    Lax.fail_with "Expected #{s.inspect}.#{mtd}(#{[*args].map(&:inspect).join ', '}) to equal #{exp.inspect} (using ==)"
  end

  def initialize(root=nil)
    @root = root
  end

  def test(subj, *ms)
    file, line = caller.first.split(?:).first(2)
    ms << truthy if ms.empty?
    ms.map {|m| __resolve_match m, subj, [file, line.to_i] }.flatten
  end

  def fail_with(str)
    Lax.fail_with str
  end

  def load(file)
    module_eval File.read(file), File.expand_path(file)
  end

  private
  def __resolve_match(match, subj, loc)
    case match
    when Hash
      match.map {|k,v| __execute_match returns(v, k, [], nil), subj, loc }
    when String, Symbol
      __execute_match __automatch(match), subj, loc
    else
      __execute_match match, subj, loc
    end
  end

  def __execute_match(matcher, subject, location)
    matcher.call subject
    r = Test.new location
  rescue Exception => xptn
    r = Test.new(location, xptn)
  ensure
    @root.transfer(r) if @root
  end

  def __automatch(mtd)
    ->(subj) { subj.__send__(mtd) or fail_with "Expected #{subj.inspect}.#{mtd} to return a true value" }
  end
end

