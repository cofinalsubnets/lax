require 'spec_helper'

describe Lax do
  let(:lax) { Class.new(Lax) }

  describe '::let' do
    before { lax.let number: 1 }
    specify { lax.methods.should include :number }
    specify { lax.instance_methods.should include :number }
    specify { lax.number.should == 1 }
    specify { lax.new.number.should == 1 }
  end

  describe '#initialize' do
    subject { lax.new }
    it { should be_empty }
  end

  describe '::scope' do
    subject { Lax.scope }
    specify { Lax.lings.should include subject }
    its(:superclass) { should == Lax  }
    its(:new) { should be_empty       }
  end

  describe '::assert' do
    subject do
      Lax.scope do
        let number: 22
        assert('hahawow') { that number == 22 }
      end.lings.last
    end
    specify   { subject.superclass.superclass.should be Lax }
    its(:doc) { should == 'hahawow'  }
    its(:new) { should have(1).thing }
  end
end

