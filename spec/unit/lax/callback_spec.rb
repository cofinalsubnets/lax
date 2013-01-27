require 'spec_helper'

describe 'callbacks' do
  let(:lax) { Lax.new }
  let(:context) { lax.context }
  let(:results) { lax.run }
  before do
    context.scope do
      before { @array = [1] }
      after  { @array << 4  }
      scope do
        assert { true }
        before { @array << 2 }
        after  { @array << 3 }
      end
    end
  end

  it 'should be executed in the correct order' do
    results.last.instance_variable_get(:@array).should == [1,2,3,4]
  end
end

