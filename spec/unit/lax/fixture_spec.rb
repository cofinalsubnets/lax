require 'spec_helper'

describe 'fixtures' do
  subject { Lax::Fixture.new class: String, upcase: 'QWER' }
  its(:class)  { should be String }
  its(:upcase) { should == 'QWER' }
  it { should be_a_kind_of Struct }
end

