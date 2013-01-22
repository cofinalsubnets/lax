require 'spec_helper'

describe Lax do
  let(:lax) { Class.new Lax }

  describe '::let' do
    subject { lax }
    shared_examples_for 'creating the correct methods' do
      its(:methods) { should include :number }
      its(:instance_methods) { should include :number }
      its(:number) { should == 1 }
      specify { lax.new('').number.should == 1 }
    end
    context 'when called with a hash' do
      before  { lax.let number: 1 }
      it_behaves_like 'creating the correct methods'
    end
    context 'when called with a symbol and block' do
      before { lax.let(:number) {1} }
      it_behaves_like 'creating the correct methods'
    end
  end

  describe '#initialize' do

    context 'when the class has an included assertion' do
      subject { Lax::TESTS.last }
      context 'and the assertion passes' do
        before { lax.assert { 'asdf' =~ /a/ } }
        it { should pass }
        it { should_not have_an_exception }
        it { should run_callbacks }
      end
      context 'and the assertion fails' do
        before { lax.assert { 1 == 2 } }
        it { should fail }
        it { should_not have_an_exception }
        it { should run_callbacks }
      end
      context 'and the assertion raises an exception' do
        before { lax.assert { 1/0 == Math::PI } }
        it { should fail }
        it { should have_an_exception ZeroDivisionError }
        it { should run_callbacks }
      end
      context 'and a callback raises an exception' do
        before do
          lax.before { NameError::Right::Here }
          lax.assert {true}
        end
        specify { ->{subject.run}.should_not raise_error }
      end
    end
  end

  describe '::scope' do
    let :scope do
      lax.scope do
        let number: 22
        assert { number == 22 }
      end
    end
    it 'should return a subclass of the receiver' do
      scope.superclass.should be lax
    end
  end
end

