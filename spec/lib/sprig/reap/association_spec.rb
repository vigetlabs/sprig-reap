require 'spec_helper'

describe Sprig::Reap::Association do
  let!(:user)    { User.create(:first_name => 'Bo', :last_name => 'Janglez') }
  let!(:post)    { Post.create(:poster => user) }
  let!(:comment) { Comment.create(:post => post) }
  let!(:vote)    { Vote.create(:votable => post) }

  let(:standard_association)    { Comment.reflect_on_all_associations(:belongs_to).first }
  let(:class_named_association) { Post.reflect_on_all_associations(:belongs_to).first }
  let(:polymorphic_association) { Vote.reflect_on_all_associations(:belongs_to).first }
  let(:habtm_association)       { Tag.reflect_on_all_associations(:has_and_belongs_to_many).first }

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

    context "given a polymorphic association" do
      subject { described_class.new(polymorphic_association) }

      its(:klass) { should == nil }
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
      subject { described_class.new(polymorphic_association) }

      its(:dependencies) { should == [Post] }
    end

    context "when the association is not polymorphic" do
      subject { described_class.new(standard_association) }

      its(:dependencies) { should == [Post] }
    end
  end

  describe "#foreign_key" do
    context "given a standard association" do
      subject { described_class.new(standard_association) }

      its(:foreign_key) { should == 'post_id' }
    end

    context "given a named association" do
      subject { described_class.new(class_named_association) }

      its(:foreign_key) { should == 'poster_id' }
    end

    context "given a polymorphic association" do
      subject { described_class.new(polymorphic_association) }

      its(:foreign_key) { should == 'votable_id' }
    end
  end

  describe "#polymorphic_type" do
    context "when the association is polymorphic" do
      subject { described_class.new(polymorphic_association) }

      its(:polymorphic_type) { should == 'votable_type' }
    end

    context "when the association is not polymorphic" do
      subject { described_class.new(standard_association) }

      its(:polymorphic_type) { should == nil }
    end
  end

  describe "#has_and_belongs_to_many?" do
    context "when the association is a has-and-belongs-to-many" do
      subject { described_class.new(habtm_association) }

      its(:has_and_belongs_to_many?) { should == true }
    end

    context "when the association is not a has-and-belongs-to-many" do
      subject { described_class.new(standard_association) }

      its(:has_and_belongs_to_many?) { should == false }
    end
  end

  describe "#has_and_belongs_to_many_attr" do
    context "when the association is a has-and-belongs-to-many" do
      subject { described_class.new(habtm_association) }

      its(:has_and_belongs_to_many_attr) { should == 'post_ids' }
    end

    context "when the association is not a has-and-belongs-to-many" do
      subject { described_class.new(standard_association) }

      its(:has_and_belongs_to_many_attr) { should == nil }
    end
  end

  describe "#foreign_key" do
    context "when the association is a has-and-belongs-to-many" do
      subject { described_class.new(habtm_association) }

      its(:foreign_key) { should == 'post_id' }
    end

    context "when the association is not a has-and-belongs-to-many" do
      subject { described_class.new(class_named_association) }

      its(:foreign_key) { should == 'poster_id' }
    end
  end
end
