require 'spec_helper'

describe Lax::Hook do
  let(:one) { Lax::Hook.new {1} }

  describe 'an instance' do
    subject { one }
    it { should be_a_kind_of Proc }
  end

  describe '#<<' do
    let(:doubler) { Lax::Hook.new {|n| 2*n} }
    subject { doubler << one }
    specify { subject.call.should == 2 }
  end

  describe '#+' do
    let(:two) { Lax::Hook.new { @num = 2 } }
    subject { (two + one).call }
    it { should == 1 }
    specify do
      subject
      @num.should == 2
    end
  end

  describe '#&' do
    let(:_true)  { Lax::Hook.new {true}  }
    let(:_false) { Lax::Hook.new {false} }
    specify do
      [
        [_true,  _true ],
        [_true,  _false],
        [_false, _true ],
        [_false, _false]
      ].each do |p1,p2|
        (p1 & p2).call.should == (p1.call && p2.call)
      end
    end
  end

  describe '::_resolve' do
    let(:resolve) { Lax::Hook.method :_resolve }
    context 'given a hook' do
      let(:hook) { Lax::Hook.new {:surprise!} }
      subject { resolve[hook] }
      it { should == hook }
    end

    context 'given a symbol' do
      let(:a_hook) { :noop }
      let(:random_sym) { :asdfqwer }
      specify { resolve[a_hook].call.should == nil }
      specify { -> {resolve[random_sym]}.should raise_error ArgumentError }
    end

  end

end

