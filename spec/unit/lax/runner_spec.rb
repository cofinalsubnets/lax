require 'spec_helper'
describe Lax::RUNNER do
  it { should be_an_instance_of Proc }
  its(:parameters) { should == [[:rest]] }

  describe 'application' do
    let(:files)   { Array.new 3, mock('file') }
    let(:results) { Array.new 6, mock('result') }
    let(:after_each) { ->(r)  { @count += 1 } }
    let(:after_all)  { ->(rs) { @final = rs.size } }
    let(:runner)     { Lax::RUNNER.call after_each, after_all }

    before do
      @count = 0
      Lax::Test.stub(:execute).with(files).and_return results
      runner.call files
    end

    specify { @count.should == 6 }
    specify { @final.should == 6 }
  end
end

