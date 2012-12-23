require 'spec_helper'

describe Lax::Target do
  let(:node) { Lax.assert { let num: 1 } }

  describe 'establishing a target' do
    subject { node.num }
    specify { (Lax::Target === subject).should == true }
    specify { subject.__val__.should == 1 }
  end

  context 'when specifying a condition' do
    before  { node.num == 1234 }
    specify { node.new.should have(1).thing }
    describe 'the entailed assertion' do
      subject { node.new.first }
      it { should be_an_instance_of Lax::Assertion  }
      its(:subject) { should be_an_instance_of Proc }
      its(:target)  { should == :num  }
      its(:matcher) { should == '=='  }
      its(:pass?)   { should == false }
    end
  end
end

