require 'spec_helper'

describe Lax do

  context 'a simple case' do
    let :simple_case do
      Lax.scope do
        let number: 19,
            string: 'asdf',
            symbol: :symbol

        assert do
          number.odd? == true
          number == 19
          string == 'asdf'
          number == 20
          string.upcase == 'ASDF'
          symbol.to_s == 'symbol'
        end
      end
    end

    subject { simple_case.new }
    it      { should have(6).things }
    specify { subject.select(&:pass?).should have(5).things }
    specify { subject.reject(&:pass?).should have(1).things }
  end

  context 'compound targets' do
    let :comp do
      Lax.scope do
        let number: 21
        let thirty: number + 9
        assert { thirty == 30 }
      end
    end
    subject { comp.new }
    it { should have(1).thing }
    specify { subject.first.pass?.should == true }
  end

end

