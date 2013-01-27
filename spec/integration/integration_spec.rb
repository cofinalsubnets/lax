require 'spec_helper'

describe Lax, clear: true do
  let(:lax) { Lax.new }
  let(:context) { lax.context }
  let(:results) { lax.run }
  let(:tests)   { lax.assertions }
  let(:pass)  { results.select &:__pass__ }
  let(:fail)  { results.reject &:__pass__ }

  describe 'a simple case' do
    before do
      context.scope do
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
    specify { results.each { |res| res.should be_a_kind_of Lax::Assertion } }
  end

  describe 'compound targets' do
    before do
      context.scope do
        let number: 21
        let thirty: number + 9
        assert { thirty == 30 }
      end
    end
    specify { tests.should have(1).things }
    specify { pass.should have(1).thing }
  end
end

