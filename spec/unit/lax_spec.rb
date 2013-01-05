require 'spec_helper'

describe Lax do
  let(:lax) { Class.new(Lax) }

  describe '::let' do
    before  { lax.let number: 1 }
    describe 'the receiver' do
      subject { lax }
      its(:methods) { should include :number }
      its(:instance_methods) { should include :number }
      its(:number) { should == 1 }
    end
  end

  describe '#initialize' do
    context 'when the class has no included assertion' do
      subject { lax.new }
      it { should_not pass }
      it { should_not have_an_exception }
      specify { lax.should_not run_callbacks }
    end

    context 'when the class has an included assertion' do
      context 'and the assertion passes' do
        let(:assertion) { lax.that { 'asdf' =~ /a/ } }
        subject { assertion.new }
        it { should pass }
        it { should_not have_an_exception }
        specify { assertion.should run_callbacks }
      end
      context 'and the assertion fails' do
        let(:assertion) { lax.that { 1 == :one } }
        subject { assertion.new }
        it { should fail }
        it { should_not have_an_exception }
        specify { assertion.should run_callbacks }
      end
      context 'and the assertion raises an exception' do
        let(:assertion) { lax.that { 1/0 == Math::PI } }
        subject { assertion.new }
        it { should fail }
        it { should have_an_exception ZeroDivisionError }
        specify { assertion.should run_callbacks }
      end
      context 'and a callback raises an exception' do
        let :bad_assertion do
          lax.assert do
            before { NameError::Right::Here }
            that { 'lalala' }
          end.lings.first
        end
        specify { ->{bad_assertion.new}.should raise_error }
      end
    end
  end

  describe '::assert' do
    let :assertion_group do
      Lax.assert do
        let number: 22
        that { number == 22 }
      end
    end
    it 'should return a subclass of the receiver' do
      assertion_group.superclass.should be Lax
    end
    describe 'the receiver' do
      specify { Lax.lings.should include assertion_group }
    end
  end
end

