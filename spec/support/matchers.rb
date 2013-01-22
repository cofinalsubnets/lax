RSpec::Matchers.define :be_an_assertion do
  match do |lax|
    lax.included_modules.map(&:class).include? Lax::Assertion
  end
end

RSpec::Matchers.define :be_an_assertion_group do
  match do |lax|
    lax.lings.any? {|ling| ling.included_modules.map(&:class).include? Lax::Assertion }
  end
end

RSpec::Matchers.define :have_an_exception do |xptn=StandardError|
  match do |lax|
    lax.run
    lax.exception.is_a?(xptn)
  end
end

RSpec::Matchers.define :pass do
  match do |lax|
    lax.run
    lax.pass
  end
end

RSpec::Matchers.define :fail do
  match do |lax|
    lax.run
    !lax.pass
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
    lax.run
    lax.instance_variable_get(:@a).should == 2
  end
end

