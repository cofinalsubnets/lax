require 'spec_helper'

describe 'callbacks' do
  let(:assertion) do
    Lax.assert do
      before { @array = [1] }
      after  { @array << 4  }
      assert do
        that { true }
        before { @array << 2 }
        after  { @array << 3 }
      end
    end.select(&:assertion).first
  end

  it 'should be executed in the correct order' do
    assertion.new.instance_variable_get(:@array).should == [1,2,3,4]
  end
end

