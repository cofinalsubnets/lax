require 'spec_helper'

describe 'a simple case' do
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
    end
  end

  subject { simple_case.lings.map &:new }
  it { should have(6).things }
  specify { subject.select(&:pass).should have(5).things }
  specify { subject.reject(&:pass).should have(1).things }
end

describe 'compound targets' do
  let :comp do
    Lax.assert do
      let number: 21
      let thirty: number + 9
      that { thirty == 30 }
    end
  end
  subject { comp.lings.map &:new }
  it { should have(1).thing }
  its(:first) { should pass }
end

