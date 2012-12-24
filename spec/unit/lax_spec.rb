require 'spec_helper'

describe Lax do
  let(:lax) { Class.new(Lax) }

  describe '::let' do
    before do
      lax.let number: 1
      lax.assert {number == 1}
    end
    specify { lax.new.should have(1).thing }
  end

  describe '#initialize' do
    subject { lax.new }
    it { should be_empty }
  end

  describe '::scope' do
    subject { Lax.scope('hahawow') {} }
    specify { Lax.lings.should include subject }
    its(:superclass) { should == Lax  }
    its(:new) { should be_empty       }
    its(:doc) { should == 'hahawow'   }
  end

  describe '::assert' do
    subject do
      Lax.scope '22' do
        let number: 22
        assert { number == 22 }
      end
    end
    its(:superclass) { should == Lax }
    its(:doc) { should == '22'       }
    its(:new) { should have(1).thing }
  end
end

