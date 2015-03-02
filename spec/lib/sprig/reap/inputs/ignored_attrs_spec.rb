require 'spec_helper'

describe Sprig::Reap::Inputs::IgnoredAttrs do
  describe ".default" do
    subject { described_class }
    
    its(:default) { should == [] }
  end

  describe ".parse" do
    let(:input) { 'boom, shaka, laka' }
    let(:ignored_attrs) { double('Sprig::Reap::Inputs::IgnoredAttrs') }

    before do
      Sprig::Reap::Inputs::IgnoredAttrs.stub(:new).with(input).and_return(ignored_attrs)
    end

    it "instantiates a Sprig::Reap::Inputs::IgnoredAttrs with the given input and grabs the list from it" do
      ignored_attrs.should_receive(:list)

      described_class.parse(input)
    end
  end

  describe "#list" do
    let(:input) { 'boom, shaka, laka' }

    subject { described_class.new(input) }

    its(:list) { should == ['boom', 'shaka', 'laka'] }
  end
end
