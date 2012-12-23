require 'spec_helper'

describe Lax::Hook do
  let(:one) { Lax::Hook.new {1} }
  specify { one.should be_a_kind_of Proc }

  describe '#<<' do
    let(:doubler) { Lax::Hook.new {|n| 2*n} }
    subject { doubler << one }
    its(:call) { should == 2 }
  end

  describe '#+' do
    let(:thing) { Object.new }
    let(:hash)  { Lax::Hook.new { thing.hash } }
    subject { hash + one }
    its(:call) { should == 1 }
    specify do
      thing.should_receive :hash
      subject.call
    end
  end

  describe '#resolve' do
    let(:resolve) { Lax::Hook.noop.method :resolve }
    context 'given a hook' do
      let(:hook) { Lax::Hook.new {:surprise!} }
      subject { resolve[hook] }
      it { should == hook }
    end

    context 'given a symbol' do
      let(:a_hook) { :noop }
      let(:random_sym) { :asdfqwer }
      specify { resolve[a_hook].should be_an_instance_of Lax::Hook        }
      specify { resolve[a_hook].call.should == nil                        }
      specify { -> {resolve[random_sym]}.should raise_error NoMethodError }
    end
  end
end

