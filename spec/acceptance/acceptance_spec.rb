require 'spec_helper'

describe Lax do

  let :simple_case do
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

  subject { simple_case.new }
  it      { should have(6).things }
  specify { subject.select(&:pass?).should have(5).things }
  specify { subject.reject(&:pass?).should have(1).things }

end

