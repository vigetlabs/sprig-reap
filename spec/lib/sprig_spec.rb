require 'spec_helper'

describe Sprig do
  describe ".reap" do
    let(:options) do
      {
        such: 'options',
        very: 'wow'
      }
    end

    it "calls Sprig::Reap.reap with the given options" do
      Sprig::Reap.should_receive(:reap).with(options)

      described_class.reap(options)
    end
  end
end
