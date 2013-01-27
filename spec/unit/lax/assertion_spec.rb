require 'spec_helper'
describe Lax::Assertion do
  let(:lax)     { Lax.new }
  let(:context) { lax.context }
  let(:cond)    { proc {1} }
  let(:assertion) { context.assert(&cond) }
  let(:instance)  { assertion.new }

  describe 'a subclass' do
    subject { assertion }
    its(:superclass) { should be context }
  end
  describe 'an instance' do
    subject { instance }
    it { should be_a_kind_of Lax::Assertion }
    its(:__source__)    { should == cond.source_location }
    its(:__pass__)      { should be 1 }
    its(:__exception__) { should be_nil }

    context 'when the class has an included assertion' do
      context 'and the assertion passes' do
        let(:cond) { proc { 'asdf' =~ /a/ } }
        it { should pass }
        it { should_not have_exception }
      end
      context 'and the assertion fails' do
        let(:cond) { proc { 1 == 2 } }
        it { should fail }
        it { should_not have_exception }
      end
      context 'and the assertion raises an exception' do
        let(:cond) { proc { 1/0 == Math::PI } }
        it { should fail }
        it { should have_exception ZeroDivisionError }
      end
      context 'and a callback raises an exception' do
        before do
          assertion.before { NameError::Right::Here }
          assertion.assert {}
        end
        it { should fail }
        it { should have_exception NameError }
      end
    end
  end

  describe '::let' do
    subject { assertion }
    shared_examples_for 'creating the correct methods' do
      its(:methods) { should include :number }
      its(:instance_methods) { should include :number }
      its(:number) { should == 1 }
      specify { assertion.new.number.should == 1 }
    end
    context 'when called with a hash' do
      before  { assertion.let number: 1 }
      it_behaves_like 'creating the correct methods'
    end
    context 'when called with a symbol and block' do
      before { assertion.let(:number) {1} }
      it_behaves_like 'creating the correct methods'
    end
  end

  describe '::scope' do
    subject do
      assertion.scope do
        let number: 22
        assert { number == 22 }
      end
    end
    its(:superclass) { should be assertion }
  end
end

