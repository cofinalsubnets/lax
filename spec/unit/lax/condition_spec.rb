require 'spec_helper'

describe 'conditions' do
  let(:lax) { Lax.new }
  let(:context) { lax.context }
  let(:results) { lax.run.map &:__pass__ }
  describe 'a simple condition' do
    before do
      context.condition(:even) {|n| n.even?}
      context.even {1}
      context.even {2}
    end
    specify { results.should == [false, true] }
  end

  describe 'a polymorphic condition' do
    before do
      context.condition(:divides) {|n,d| n%d == 0 }
      context.divides(10) {6}
      context.divides(10) {5}
    end
    specify { results.should == [false, true] }
  end
end

