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
  match { |lax| lax.exception.is_a?(xptn) }
end

RSpec::Matchers.define :pass do
  match { |lax| lax.pass }
end

RSpec::Matchers.define :fail do
  match { |lax| !lax.pass }
end

RSpec::Matchers.define :run_callbacks do
  match do |lax|
    lax.before { @num = 0 }
    lax.after  { @num += 1 }
    lax.new.instance_variable_get(:@num) == 1
  end
end

