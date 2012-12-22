require 'spec_helper'

describe Lax::Assertion::Node do
  let(:root) { Lax::Assertion::Node.assert {} }
  subject { root }

  describe '::let' do
    before { root.let number: 1 }
    its(:defs) { should have(1).thing }
  end

  describe '#initialize' do
    subject { root.new }
    before  { root.assert {} }
    its(:assertions) { should be_empty }
    its(:children)   { should have(1).thing }
  end

end

