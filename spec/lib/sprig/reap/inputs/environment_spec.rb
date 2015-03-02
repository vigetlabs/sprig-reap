require 'spec_helper'

describe Sprig::Reap::Inputs::Environment do
  before do
    stub_rails_root
  end

  describe ".default" do
    subject { described_class }

    its(:default) { should == 'test' }
  end

  describe ".parse" do
    let(:environment) { double('Sprig::Reap::Inputs::Environment') }

    before do
      Sprig::Reap::Inputs::Environment.stub(:new).with(:shaboosh).and_return(environment)
    end

    it "instantiates a Sprig::Reap::Inputs::Environment and returns the env from it" do
      environment.should_receive(:env)

      described_class.parse(:shaboosh)
    end
  end

  describe "#env" do
    context "when no input is given" do
      subject { described_class.new }

      its(:env) { should == 'test' }
    end

    context "when the input is a blank value" do
      subject { described_class.new(nil) }

      its(:env) { should == 'test' }
    end

    context "when the input is a string" do
      subject { described_class.new(' ShaBOOSH') }

      it "formats the given value and then sets the target environment" do
        subject.env.should == 'shaboosh'
      end

      context "and the corresponding seeds folder does not yet exist" do
        after do
          FileUtils.remove_dir('./spec/fixtures/db/seeds/shaboosh')
        end

        it "creates the seeds folder" do
          subject.env

          File.directory?('./spec/fixtures/db/seeds/shaboosh').should == true
        end
      end
    end

    context "given a symbol" do
      subject { described_class.new(:shaboosh) }

      it "formats the given value and then sets the target environment" do
        subject.env.should == 'shaboosh'
      end

      context "and the corresponding seeds folder does not yet exist" do
        after do
          FileUtils.remove_dir('./spec/fixtures/db/seeds/shaboosh')
        end

        it "creates the seeds folder" do
          subject.env

          File.directory?('./spec/fixtures/db/seeds/shaboosh').should == true
        end
      end
    end
  end
end
