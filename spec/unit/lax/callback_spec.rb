require 'spec_helper'

describe 'callbacks' do
  let(:lax)  { Class.new Lax }
  let(:test) { Lax::TESTS.last }
  before do
    lax.scope do
      before { @array = [1] }
      after  { @array << 4  }
      scope do
        assert { true }
        before { @array << 2 }
        after  { @array << 3 }
      end
    end
    test.run
  end

  it 'should be executed in the correct order' do
    test.instance_variable_get(:@array).should == [1,2,3,4]
  end
end

