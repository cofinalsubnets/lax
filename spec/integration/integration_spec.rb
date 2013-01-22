require 'spec_helper'

describe Lax, clear: true do
  let(:lax)   { Class.new Lax }
  let(:tests) { Lax::TESTS.each &:run }
  let(:pass)  { tests.select &:pass }
  let(:fail)  { tests.reject &:pass }

  describe 'a simple case' do
    before do
      lax.scope do
        let number: 19,
            string: 'asdf',
            symbol: :symbol

        assert { number.odd? == true     }
        assert { number == 19            }
        assert { string == 'asdf'        }
        assert { number == 20            }
        assert { string.upcase == 'ASDF' }
        assert { symbol.to_s == 'symbol' }
      end
    end

    specify { tests.should have(6).things }
    specify { pass.should have(5).things }
    specify { fail.should have(1).thing }
  end

  describe 'compound targets' do
    before do
      Lax.scope do
        let number: 21
        let thirty: number + 9
        assert { thirty == 30 }
      end
    end
    specify { tests.should have(1).things }
    specify { pass.should have(1).thing }
  end
end

