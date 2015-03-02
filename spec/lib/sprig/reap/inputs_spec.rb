require 'spec_helper'

describe Sprig::Reap::Inputs do
  describe "Model()" do
    context "given a non-Sprig::Reap::Inputs::Model" do
      it "instantiates a Sprig::Reap::Inputs::Model with the given input" do
        described_class.Model(Post).should be_an_instance_of Sprig::Reap::Inputs::Model
      end
    end

    context "given a Sprig::Reap::Inputs::Model" do
      let(:input) { Sprig::Reap::Inputs::Model.new(Post) }

      it "returns the given input" do
        described_class.Model(input).should == input
      end
    end
  end
end
