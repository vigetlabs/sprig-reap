require 'spec_helper'

describe Sprig::Reap::Association do
  let!(:user)    { User.create(:first_name => 'Bo', :last_name => 'Janglez') }
  let!(:post)    { Post.create(:poster => user) }
  let!(:comment) { Comment.create(:post => post) }
  let!(:vote)    { Vote.create(:votable => post) }

  let(:standard_association)    { Comment.reflect_on_all_associations(:belongs_to).first }
  let(:class_named_association) { Post.reflect_on_all_associations(:belongs_to).first }
  let(:polymorphic_association) { Vote.reflect_on_all_associations(:belongs_to).first }

  describe "#polymorphic?" do
    context "when given a non-polymorphic dependency" do
      subject { described_class.new(standard_association) }

      its(:polymorphic?) { should == false }
    end

    context "when given a polymorphic dependency" do
      subject { described_class.new(polymorphic_association) }

      its(:polymorphic?) { should == true }
    end
  end

  describe "#klass" do
    context "given a standard association" do
      subject { described_class.new(standard_association) }

      its(:klass) { should == Post }
    end

    context "given a named association" do
      subject { described_class.new(class_named_association) }

      its(:klass) { should == User }
    end
  end

  describe "#polymorphic_dependencies" do
    context "when the association is not polymorphic" do
      subject { described_class.new(standard_association) }

      its(:polymorphic_dependencies) { should == [] }
    end

    context "when the association is polymorphic" do
      subject { described_class.new(polymorphic_association) }

      its(:polymorphic_dependencies) { should == [Post] }
    end
  end

  describe "#polymorphic_match?" do
    context "when the given model does not have a matching polymorphic association" do
      subject { described_class.new(polymorphic_association) }

      it "returns false" do
        subject.polymorphic_match?(User).should == false
      end
    end

    context "when the given model has a matching polymorphic association" do
      subject { described_class.new(polymorphic_association) }

      it "returns true" do
        subject.polymorphic_match?(Post).should == true
      end
    end
  end

  describe "#dependencies" do
    context "when the association is polymorphic" do
      subject { described_class.new(standard_association) }

      its(:dependencies) { should == [Post] }
    end

    context "when the association is not polymorphic" do
      subject { described_class.new(polymorphic_association) }

      its(:dependencies) { should == [Post] }
    end
  end
end
