require 'spec_helper'

describe Sprig::Reap::Configuration do
  subject { described_class.new }

  before do
    stub_rails_root
  end

  describe "#target_env" do
    context "from a fresh configuration" do
      its(:target_env) { should == Rails.env }
    end
  end

  describe "#target_env=" do
    context "when given nil" do
      it "does not change the target_env" do
        subject.target_env = nil

        subject.target_env.should_not == nil
      end
    end

    context "given a non-nil string value" do
      let(:input) { ' ShaBOOSH' }

      it "formats the given value and then sets the target environment" do
        subject.target_env = input

        subject.target_env.should == 'shaboosh'
      end

      context "and the corresponding seeds folder does not yet exist" do
        after do
          FileUtils.remove_dir('./spec/fixtures/db/seeds/shaboosh')
        end

        it "creates the seeds folder" do
          subject.target_env = input

          File.directory?('./spec/fixtures/db/seeds/shaboosh').should == true
        end
      end
    end

    context "given a non-nil symbol value" do
      let(:input) { :shaboosh }

      it "formats the given value and then sets the target environment" do
        subject.target_env = input

        subject.target_env.should == 'shaboosh'
      end

      context "and the corresponding seeds folder does not yet exist" do
        after do
          FileUtils.remove_dir('./spec/fixtures/db/seeds/shaboosh')
        end

        it "creates the seeds folder" do
          subject.target_env = input

          File.directory?('./spec/fixtures/db/seeds/shaboosh').should == true
        end
      end
    end
  end

  describe "#classes" do
    context "from a fresh configuration" do
      its(:classes) { should == ActiveRecord::Base.subclasses }
    end
  end

  describe "#classes=" do
    context "when given nil" do
      it "does not set classes to nil" do
        subject.classes = nil

        subject.classes.should_not == nil
      end
    end

    context "when given an array of classes" do
      context "where one or more classes are not subclasses of ActiveRecord::Base" do
        it "raises an error" do
          expect {
            subject.classes = [Comment, Sprig::Reap::Model]
          }.to raise_error ArgumentError, 'Cannot create a seed file for Sprig::Reap::Model because it is not a subclass of ActiveRecord::Base.'
        end
      end

      context "where all classes are subclasses of ActiveRecord::Base" do
        it "sets classes to the given input" do
          subject.classes = [Comment, Post]

          subject.classes.should == [Comment, Post]
        end
      end
    end

    context "when given a string" do
      context "where one or more classes are not subclasses of ActiveRecord::Base" do
        it "raises an error" do
          expect {
            subject.classes = 'Sprig::Reap::Model'
          }.to raise_error ArgumentError, 'Cannot create a seed file for Sprig::Reap::Model because it is not a subclass of ActiveRecord::Base.'
        end
      end

      context "where all classes are subclasses of ActiveRecord::Base" do
        it "sets classes to the parsed input" do
          subject.classes = ' comment, post'

          subject.classes.should == [Comment, Post]
        end
      end
    end
  end

  describe "#ignored_attrs" do
    context "from a fresh configuration" do
      its(:ignored_attrs) { should == [] }
    end
  end

  describe "#ignored_attrs=" do
    context "when given nil" do
      before { subject.classes = nil }

      its(:ignored_attrs) { should == [] }
    end

    context "when given an array of ignored_attrs" do
      before { subject.ignored_attrs = [:shaka, ' laka '] }

      its(:ignored_attrs) { should == ['shaka', 'laka'] }
    end

    context "when given a string" do
      before { subject.ignored_attrs = ' shaka, laka' }

      its(:ignored_attrs) { should == ['shaka', 'laka'] }
    end
  end

  describe "#logger" do
    it "initializes a new logger" do
      Logger.should_receive(:new)

      subject.logger
    end
  end
end
