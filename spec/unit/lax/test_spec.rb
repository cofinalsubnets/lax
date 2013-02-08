require 'spec_helper'
describe Lax::Test do
  specify { described_class.should include MiniTest::Assertions }

  describe '::group' do
    it "creates a new subclass of Test" do
      Lax::Test.group.superclass.should be Lax::Test
    end

    it "evaluates a given block in the context of the new class" do
      group = Lax::Test.group { def self.number; 1 end }
      group.number.should == 1
    end
  end

  describe '::assert' do
    let(:fiber) { Fiber.new { assertion } }
    let(:assertion) { Lax::Test.assert { nil } }
    let(:value) { fiber.resume }

    it 'yields a Test::Result to the calling fiber' do
      value.should be_an_kind_of Lax::Test::Result
    end
  end

  describe '::let' do
    let(:group) { Lax::Test.group }
    context 'called with a hash' do
      it 'creates the appropriate methods' do
        group.let number: 1, name: 'frank'
        group.number.should == 1
        group.new.number.should == 1
        group.name.should == 'frank'
        group.new.name.should == 'frank'
      end
    end

    context 'called with a symbol and a block' do
      it 'creates the appropriate methods' do
        group.let(:radius) {15}
        group.radius.should == 15
        group.new.radius.should == 15
      end
    end
  end

  describe 'callbacks' do
    let(:group) { Lax::Test.group }
    let(:executed_test) do
      t = group.new
      t.__execute__ ->{}
      t
    end
    let(:number) { executed_test.instance_variable_get :@number }

    describe '::before' do
      it 'sets the before callback for test instances' do
        group.before { @number = 1 }
        number.should == 1
      end

      it 'stacks correctly with repeated invocations' do
        group.before { @number  = 1 }
        group.before { @number += 1 }
        number.should == 2
      end
    end

    describe '::after' do
      it 'sets the after callback for test instances' do
        group.after { @number = 1 }
        number.should == 1
      end

      it 'stacks correctly with repeated invocations' do
        group.after { @number += 1 }
        group.after { @number  = 1 }
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

  end

end

