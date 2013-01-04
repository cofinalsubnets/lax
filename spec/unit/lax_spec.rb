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
    its(:pass) { should be_nil }
    its(:exception) { should be_nil }
  end

  describe '::assert' do
    subject { Lax.assert }
    specify { Lax.lings.should include subject }
  end

  describe '::assert' do
    let :assertion do
      Lax.assert do
        let number: 22
        that { number == 22 }
      end.lings.last.new
    end
    subject { assertion }
    specify { assertion.class.superclass.superclass.should be Lax }
    its(:pass) { should be_true }
    its(:exception) { should be_nil }
  end
end

