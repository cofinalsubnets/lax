RSpec::Matchers.define :have_exception do |xptn=StandardError|
  match do |lax|
    lax.__exception__.is_a?(xptn)
  end
end

RSpec::Matchers.define :pass do
  match do |lax|
    lax.__pass__
  end
end

RSpec::Matchers.define :fail do
  match do |lax|
    !lax.__pass__
  end
end

RSpec::Matchers.define :run_callbacks do
  match do |lax|
    def lax.before
      @a=1
    end
    def lax.after
      @a+=1
    end
    lax.new.instance_variable_get(:@a).should == 2
  end
end

