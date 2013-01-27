let(:lax)     { Lax.new }
let(:context) { lax.context }

scope do
  let(:test) { lax.assertions.first.new }
  before do
    context.scope do
      assert {1}
    end
  end

  assert { lax.assertions.size == 1 }
  assert { test.__pass__ }
end

