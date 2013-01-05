require 'spec_helper'

describe 'a subclass' do
  subject { Class.new(Lax) }
  its(:assertion) { should be nil }
  its(:lings) { should == [] }
  it "should be added to its parent's list of subclasses" do
    Lax.lings.should include subject
  end
end

