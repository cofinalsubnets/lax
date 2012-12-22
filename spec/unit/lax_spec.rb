require 'spec_helper'

describe Lax do
  subject { Lax }

  describe '::let' do
    before do
      Lax.let number: 1
      Lax.number == 1
    end
    subject { Lax.instance_methods - Lax.superclass.instance_methods }
    it { should have(1).thing }
  end

  describe '#initialize' do
    subject { Lax.reboot.new }
    it { should be_empty }
  end
end

