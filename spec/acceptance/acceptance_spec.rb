require 'spec_helper'

describe Lax do

  context 'a simple case' do
    let :simple_case do
      Lax.assert do
        let number: 19,
            string: 'asdf',
            symbol: :symbol

        that { number.odd? == true     }
        that { number == 19            }
        that { string == 'asdf'        }
        that { number == 20            }
        that { string.upcase == 'ASDF' }
        that { symbol.to_s == 'symbol' }
      end.lings.map &:new
    end

    specify { simple_case.should have(6).things }
    specify { simple_case.select(&:pass).should have(5).things }
    specify { simple_case.reject(&:pass).should have(1).things }
  end

  context 'compound targets' do
    let :comp do
      Lax.assert do
        let number: 21
        let thirty: number + 9
        that { thirty == 30 }
      end
    end
    subject { comp.lings.map &:new }
    it { should have(1).thing }
    specify { subject.first.pass.should == true }
  end
end

