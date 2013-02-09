class Lax
  def self.matcher(name, &matcher)
    define_method name, &matcher.curry
  end

  def satisfies(&cond)
    ->(s) do
      cond.call(s) or
      fail_with "Expected #{s.inspect} to satisfy a condition defined at #{cond.source_location}"
    end
  end

  def fail_with(str)
    raise TestFailure, str
  end

  def automatch(sym, *args)
    ->(subj) do
      subj.__send__(sym, *args) or
      fail_with "Expected #{subj.inspect}.#{sym}(#{args.map(&:inspect).join ', '}) to return a true value"
    end
  end

  def method_missing(msg, *args)
    msg.to_s =~ /(is|does)_(.+)/ ? automatch("#{$2}?", *args) : super
  end

  matcher :truish do |s|
    s or fail_with "Expected #{s.inspect} to be a true value"
  end

  matcher :is do |o,s|
    s.equal?(o) or
    fail_with "Expected: #{o.inspect}\nGot: #{s.inspect}\n(using equal?)"
  end

  matcher :equals do |o,s|
    s==o or
    fail_with "Expected: #{o.inspect}\nGot: #{s.inspect}\n(using ==)"
  end

  matcher :contains do |n, mtc, subj|
    subj.select {|e| mtc===e}.size == n or
    fail_with "Expected #{subj.inspect} to have #{n} elements matching #{mtc.inspect}"
  end
end

