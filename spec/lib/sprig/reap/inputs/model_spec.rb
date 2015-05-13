require 'spec_helper'

describe Sprig::Reap::Inputs::Model do
  describe ".valid_classes" do
    subject { described_class }

    its(:valid_classes) { should == ActiveRecord::Base.subclasses }
  end

  describe ".default" do
    it "instantiates a Sprig::Reap::Inputs::Model for each model" do
      ActiveRecord::Base.subclasses.each do |model|
        Sprig::Reap::Inputs::Model.should_receive(:new).with(model)
      end

      described_class.default
    end
  end

  describe ".parse" do
    context "given a list in a string" do
      it "instantiates a Sprig::Reap::Inputs::Model for each piece of input" do
        Sprig::Reap::Inputs::Model.should_receive(:new).with('User')
        Sprig::Reap::Inputs::Model.should_receive(:new).with('Post.published')
        Sprig::Reap::Inputs::Model.should_receive(:new).with('Tag')

        described_class.parse('User, Post.published, Tag')
      end
    end

    context "given an array" do
      it "instantiates a Sprig::Reap::Inputs::Model for each piece of input" do
        Sprig::Reap::Inputs::Model.should_receive(:new).with(User)
        Sprig::Reap::Inputs::Model.should_receive(:new).with(Post.published)
        Sprig::Reap::Inputs::Model.should_receive(:new).with(Tag)

        described_class.parse([User, Post.published, Tag])
      end
    end

    context "given a single item" do
      it "instantiates a Sprig::Reap::Inputs::Model with the input" do
        Sprig::Reap::Inputs::Model.should_receive(:new).with(Post.published)

        described_class.parse(Post.published)
      end
    end

    context "given nil" do
      it "returns nil" do
        described_class.parse(nil).should == nil
      end
    end
  end

  describe "#initialize" do
    context "when the input is a String" do
      context "representing an ActiveRecord::Base class" do
        it "does not raise an error" do
          expect { described_class.new('User') }.to_not raise_error
        end
      end

      context "representing an ActiveRecord::Relation" do
        it "does not raise an error" do
          expect { described_class.new('Post.published') }.to_not raise_error
        end
      end

      context "representing a non-ActiveRecord::Base class" do
        it "raises an error" do
          expect { described_class.new('Sprig::Reap::Model') }.to raise_error
        end
      end

      context "representing some non-class identifier" do
        it "raises an error" do
          expect { described_class.new('klass') }.to raise_error
        end
      end
    end

    context "when the input is a non-ActiveRecord::Base class" do
      it "raises an error" do
        expect { described_class.new(Sprig::Reap::Record) }.to raise_error
      end
    end

    context "when the input is an ActiveRecord::Base class" do
      it "does not raise an error" do
        expect { described_class.new(Tag) }.to_not raise_error
      end
    end

    context "when the input is an ActiveRecord::Relation" do
      it "does not raise an error" do
        expect { described_class.new(Post.published) }.to_not raise_error
      end
    end
  end

  describe "#klass" do
    context "when the input is an ActiveRecord::Base class" do
      subject { described_class.new(Tag) }

      its(:klass) { should == Tag }
    end

    context "when the input is an ActiveRecord::Relation" do
      subject { described_class.new(Post.published) }

      its(:klass) { should == Post }
    end
  end

  describe "#records" do
    let!(:bob)  { User.create(:first_name => 'Bob',  :last_name => 'Costas') }
    let!(:john) { User.create(:first_name => 'John', :last_name => 'Madden') }

    context "when the input is an ActiveRecord::Base class" do
      subject { described_class.new(User) }

      its(:records) { should == [bob, john]}
    end

    context "when the input is an ActiveRecord::Relation" do
      let!(:unpublished) { Post.create(:published => false, :poster => bob) }
      let!(:published)   { Post.create(:published => true,  :poster => john) }

      subject { described_class.new(Post.published) }

      its(:records) { should == [published] }
    end
  end
end
