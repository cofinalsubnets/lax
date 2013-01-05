require 'spec_helper'

describe 'a simple condition' do
  before  { Lax.condition(:even) {|n| n.even?} }
  specify { Lax.even {1}.new.should fail }
  specify { Lax.even {2}.new.should pass }
end

describe 'a polymorphic condition' do
  before  { Lax.condition(:divides) {|n,d| n%d == 0 } }
  specify { Lax.divides(10) {6}.new.should fail }
  specify { Lax.divides(10) {5}.new.should pass }
end

