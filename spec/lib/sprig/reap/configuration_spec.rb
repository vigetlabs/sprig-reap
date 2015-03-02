require 'spec_helper'

describe Sprig::Reap::Configuration do
  subject { described_class.new }

  before do
    stub_rails_root
  end

  describe "#target_env" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::Environment.should_receive(:default)

        subject.target_env
      end
    end
  end

  describe "#target_env=" do
    it "parses the input" do
      Sprig::Reap::Inputs::Environment.should_receive(:parse).with(:shaboosh)

      subject.target_env = :shaboosh
    end
  end

  describe "#models" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::Model.should_receive(:default)

        subject.models
      end
    end
  end

  describe "#models=" do
    it "parses the input" do
      Sprig::Reap::Inputs::Model.should_receive(:parse).with(Post)

      subject.models = Post
    end
  end

  describe "#ignored_attrs" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::IgnoredAttrs.should_receive(:default)

        subject.ignored_attrs
      end
    end
  end

  describe "#ignored_attrs=" do
    it "parses the input" do
      Sprig::Reap::Inputs::IgnoredAttrs.should_receive(:parse).with('boom, shaka, laka')

      subject.ignored_attrs = 'boom, shaka, laka'
    end
  end

  describe "#logger" do
    it "initializes a new logger" do
      Logger.should_receive(:new)

      subject.logger
    end
  end

  describe "#omit_empty_attrs" do
    context "from a fresh configuration" do
      its(:omit_empty_attrs) { should == false }
    end
  end

  describe "#omit_empty_attrs" do
    context "when given nil" do
      before { subject.omit_empty_attrs = nil }

      its(:omit_empty_attrs) { should == false }
    end

    context "when given a word other than true" do
      before { subject.omit_empty_attrs = ' Shaboosh' }

      its(:omit_empty_attrs) { should == false }
    end

    context "when given true" do
      before { subject.omit_empty_attrs = 'True' }

      its(:omit_empty_attrs) { should == true }
    end
  end
end
