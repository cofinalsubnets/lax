require 'spec_helper'

describe 'conditions' do
  let(:results) { Lax::TESTS.each(&:run).map(&:pass) }
  describe 'a simple condition' do
    let(:results) { Lax::TESTS.each(&:run).map(&:pass) }
    before do
      Lax.condition(:even) {|n| n.even?}
      Lax.even {1}
      Lax.even {2}
    end
    specify { results.should == [false, true] }
  end

  describe 'a polymorphic condition' do
    before do
      Lax.condition(:divides) {|n,d| n%d == 0 }
      Lax.divides(10) {6}
      Lax.divides(10) {5}
    end
    specify { results.should == [false, true] }
  end
end

