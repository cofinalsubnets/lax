require 'spec_helper'

describe Lax::Fixture::Hashable do
  let(:hash) { { name: 'phyllis', fears: { mild: ['spiders'], severe: ['manatees'] } } }
  let(:config) { Lax::Fixture::Hashable.new hash }

  describe '::new' do
    specify { ->{Lax::Fixture::Hashable.new}.should raise_error ArgumentError }
    specify { [:name, :fears].each {|msg| config.should respond_to msg } }
    specify { config.name.should == 'phyllis' }
    specify { config.fears.should be_a_kind_of Lax::Fixture::Hashable }
  end

  describe '#merge' do
    subject { config.merge manners: 'impeccable' }
    it { should be_a_kind_of Lax::Fixture::Hashable }
    specify { subject.name.should == 'phyllis' }
    specify { subject.manners.should == 'impeccable' }
    specify { subject.fears.should be_a_kind_of Lax::Fixture::Hashable }
  end

  describe '#to_hash' do
    subject { config.to_hash }
    it { should == hash }
  end
end

