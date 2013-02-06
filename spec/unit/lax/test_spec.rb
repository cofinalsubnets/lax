require 'spec_helper'
describe Lax::Test do
  specify { described_class.should include MiniTest::Assertions }

  describe '::scope' do
    it "creates a new subclass of Test" do
      Lax::Test.scope.superclass.should be Lax::Test
    end

    it "evaluates a given block in the context of the new class" do
      scope = Lax::Test.scope { def self.number; 1 end }
      scope.number.should == 1
    end
  end

  describe '::assert' do
    let(:fiber) { Fiber.new { assertion } }
    let(:assertion) { Lax::Test.assert { nil } }
    let(:value) { fiber.resume }

    it 'yields a Test::Result to the calling fiber' do
      value.should be_an_instance_of Lax::Test::Result
    end
  end

  describe '::let' do
    let(:scope) { Lax::Test.scope }
    context 'called with a hash' do
      it 'creates the appropriate methods' do
        scope.let number: 1, name: 'frank'
        scope.number.should == 1
        scope.new.number.should == 1
        scope.name.should == 'frank'
        scope.new.name.should == 'frank'
      end
    end

    context 'called with a symbol and a block' do
      it 'creates the appropriate methods' do
        scope.let(:radius) {15}
        scope.radius.should == 15
        scope.new.radius.should == 15
      end
    end
  end

  describe 'callbacks' do
    let(:scope) { Lax::Test.scope }
    let(:executed_test) do
      t = scope.new
      t.__execute__ ->{}
      t
    end
    let(:number) { executed_test.instance_variable_get :@number }

    describe '::before' do
      it 'sets the before callback for test instances' do
        scope.before { @number = 1 }
        number.should == 1
      end

      it 'stacks correctly with repeated invocations' do
        scope.before { @number  = 1 }
        scope.before { @number += 1 }
        number.should == 2
      end
    end

    describe '::after' do
      it 'sets the after callback for test instances' do
        scope.after { @number = 1 }
        number.should == 1
      end

      it 'stacks correctly with repeated invocations' do
        scope.after { @number += 1 }
        scope.after { @number  = 1 }
        number.should == 2
      end
    end
  end

  describe 'assertions' do
    let(:test) { Lax::Test.new }
    describe 'with MiniTest::Assertions' do
      specify do
        test.assert_equal('asdf', 'asdf').should be_true
        -> { test.assert_equal 'asdf', 'qwer' }.should raise_error MiniTest::Assertion
      end
    end

    describe 'with Lax::Target' do
      specify do
        (test.that('asdf') == 'asdf').should be_true
        -> { test.that('asdf') == 'qwer' }.should raise_error MiniTest::Assertion
      end
    end
  end

end

