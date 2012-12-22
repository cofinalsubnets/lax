require 'spec_helper'

describe Lax::Assertion::Subject do
  let(:node) { Lax::Assertion::Node.assert { let num: 1 } }

  describe 'specifying a condition' do
    subject { node }
    before  { node.num == 1234 }
    its(:assertions)       { should == [:num_0] }
    its(:instance_methods) { should include :num_0 }
    describe 'the created assertion' do
      subject { node.new.num_0 }
      before  { subject.validate }
      its(:pass?) { should be_false }
      its(:value) { should == 1 }
    end
  end

  describe 'method chains' do
  end

end

