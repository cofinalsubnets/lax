require 'spec_helper'

describe Lax do
  let(:instance) { Lax.new }
  specify { Lax.instance.should be_an_instance_of Lax }

  describe 'a new instance' do
    subject { instance }
    its(:runner) { should be_an_instance_of Lax::Runner }
    specify { instance.context.superclass.should be Lax::Assertion }
  end

  describe '#load' do
    let(:files) {[]}
    let(:file) { '/tmp/bluh.rb' }
    let(:file_ary) { %w( tmp/bluh.rb tmp/gluh.rb ) }
    before do
      File.stub(:open) {|f| files << f}
    end
    context 'given a file' do
      before  { instance.load file }
      specify { files.should == [file] }
    end
    context 'given an array of files' do
      before  { instance.load file_ary }
      specify { files.should == file_ary }
    end
    context 'given multiple file arguments' do
      before  { instance.load *file_ary }
      specify { files.should == file_ary }
    end
  end

  describe '#run' do
    let(:runner) { instance.runner }
    let(:tests)  { instance.assertions }
    let(:results) { mock 'results' }
    it 'creates and runs a new Runner' do
      runner.stub(:run).with(tests).and_return results
      instance.run.should be results
    end
  end

end

