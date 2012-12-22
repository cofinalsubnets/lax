require 'spec_helper'

describe Lax::Tree do
  let(:tree) do
    tree = Lax::Tree.new
    3.times do
      tree.children.push(child = Lax::Tree.new)
      3.times do
        child.children.push Lax::Tree.new
      end
    end
    tree
  end

  describe '#each' do
    subject { tree.to_a } # implementation from Enumerable via #each
    it { should have(13).things }
    specify { subject.each {|node| node.should be_an_instance_of Lax::Tree } }
    specify { subject.map(&:__id__).uniq.should have(13).things }
  end
end

