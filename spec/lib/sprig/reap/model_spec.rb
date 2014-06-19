require 'spec_helper'

describe Sprig::Reap::Model do
  describe ".all" do
    let(:all_models) do
      [
        described_class.new(User),
        described_class.new(Post),
        described_class.new(Comment),
        described_class.new(Vote)
      ]
    end

    before do
      Sprig::Reap.stub(:classes).and_return([Comment, Post, User, Vote])
    end

    it "returns an dependency-sorted array of Sprig::Reap::Models" do
      described_class.all.all? { |model| model.is_a? Sprig::Reap::Model }.should == true
      described_class.all.map(&:klass).should == all_models.map(&:klass)
    end
  end

  describe ".find" do
    let!(:user)      { User.create(:first_name => 'Bo', :last_name => 'Janglez') }
    let!(:post1)     { Post.create }
    let!(:post2)     { Post.create }
    let!(:comment1)  { Comment.create(:post => post1) }
    let!(:comment2)  { Comment.create(:post => post2) }

    subject { described_class }

    it "returns the Sprig::Reap::Record for the given class and id" do
      subject.find(User, 1).record.should == user
      subject.find(Post, 1).record.should == post1
      subject.find(Post, 2).record.should == post2
      subject.find(Comment, 1).record.should == comment1
      subject.find(Comment, 2).record.should == comment2
    end
  end

  describe "#attributes" do
    let(:attrs) { %w(boom shaka laka) }

    subject { described_class.new(User) }

    before do
      User.stub(:column_names).and_return(attrs)
    end

    context "when there are no ignored attributes" do
      its(:attributes) { should == attrs }
    end

    context "when there are ignored attributes" do
      before do
        Sprig::Reap.stub(:ignored_attrs).and_return(['laka'])
      end

      its(:attributes) { should == ['boom', 'shaka'] }
    end
  end

  describe "#dependencies" do
    subject { described_class.new(Comment) }

    its(:dependencies) { should == [Post] }

    context "when the model is polymorphic" do
      subject { described_class.new(Vote) }

      its(:dependencies) { should == [Post] }
    end

    context "when the model has a dependency with an explicit :class_name" do
      subject { described_class.new(Post) }

      its(:dependencies) { should == [User] }
    end
  end

  describe "#associations" do
    let(:association) { double('Association') }

    subject { described_class.new(Post) }

    before do
      Post.stub(:reflect_on_all_associations).with(:belongs_to).and_return([association])
    end

    it "creates an Association object for each belongs to association the model has" do
      Sprig::Reap::Association.should_receive(:new).with(association)

      subject.associations
    end
  end

  describe "#find" do
    let!(:post1) { Post.create }
    let!(:post2) { Post.create }

    subject { described_class.new(Post) }

    it "returns the Sprig::Reap::Record with the given id" do
      reap_record = subject.find(2)
      reap_record.should be_an_instance_of Sprig::Reap::Record
      reap_record.record.should == post2
    end
  end

  describe "#generate_sprig_id" do
    subject { described_class.new(Comment) }

    context "when the existing sprig_ids are all integers" do
      before do
        subject.existing_sprig_ids = [5, 20, 8]
      end

      it "returns an integer-type sprig_id that is not taken" do
        subject.generate_sprig_id.should == 21
      end
    end

    context "when the existing sprig ids contain non-integer values" do
      before do
        subject.existing_sprig_ids = [1, 5, 'l_2', 'l_10', 'such_sprigs', 10.9]
      end
      it "returns an integer-type sprig_id that is not taken" do
        subject.generate_sprig_id.should == 6
      end
    end
  end

  describe "#to_s" do
    subject { described_class.new(Comment) }

    its(:to_s) { should == "Comment" }
  end

  describe "#to_yaml" do
    let!(:user)      { User.create(:first_name => 'Bo', :last_name => 'Janglez') }
    let!(:post1)     { Post.create }
    let!(:post2)     { Post.create }
    let!(:comment1)  { Comment.create(:post => post1) }
    let!(:comment2)  { Comment.create(:post => post2) }

    subject { described_class.new(Comment) }

    context "when passed a value for the namespace" do
      it "returns the correct yaml" do
        subject.to_yaml(:namespace => 'records').should == yaml_from_file('records_with_namespace.yml')
      end
    end

    context "when no namespace is given" do
      it "returns the correct yaml" do
        subject.to_yaml.should == yaml_from_file('records_without_namespace.yml')
      end
    end
  end

  def yaml_from_file(basename)
    File.read('spec/fixtures/yaml/' + basename)
  end
end
