require 'spec_helper'

describe Lax do
  let(:lax) { Class.new(Lax) }

  describe '::let' do
    before do
      lax.let number: 1
      lax.number == 1
    end
    subject { lax.instance_methods - Lax.instance_methods }
    it { should have(1).thing }
  end

  describe '#initialize' do
    subject { lax.new }
    it { should be_empty }
  end

  describe '::assert' do
    specify { ->{ Lax.assert }.should raise_error ArgumentError }
    subject { Lax.assert('hahawow') {}     }
    its(:superclass) { should be Lax       }
    its(:doc)        { should == 'hahawow' }
    its(:new)        { should be_empty     }
    specify { Lax.lings.should include subject }
  end
end

