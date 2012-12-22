require 'spec_helper'

describe Lax do
  describe 'test case with let' do

    let :assertion_tree do
      Lax.assert do
        let number: 19,
            string: 'asdf',
            symbol: :symbol

        number.odd? == true
        number == 19
        string == 'asdf'
        number == 20
        string.upcase == 'ASDF'
        symbol.to_s == 'symbol'
      end
    end

    subject { assertion_tree.new }

    specify { subject.assertions.flatten.should have(6).things }

  end


end

