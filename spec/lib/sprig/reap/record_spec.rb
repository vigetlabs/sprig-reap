require 'spec_helper'

class Very; end

describe Sprig::Reap::Record do
  let!(:user) { User.create(:first_name => 'Bo', :last_name => 'Janglez') }

  let!(:post) do
    Post.create(:poster    => user,
                :title     => 'Such Title',
                :content   => 'Very Content',
                :published => true)
  end

  let!(:posterless_post) do
    Post.create(:poster    => nil,
                :title     => 'Wow Title',
                :content   => 'Much Content',
                :published => false)
  end

  let!(:models) { Sprig::Reap::Model.all }
  let!(:model)  { models.find { |model| model.klass == Post } }

  describe "#id" do
    subject { described_class.new(post, model) }

    its(:id) { should == post.id }
  end

  describe "#attributes" do
    subject { described_class.new(post, model) }

    it "returns an array of attributes from the given model sans id" do
      subject.attributes.should == %w(
        title
        content
        published
        poster_id
      )
    end
  end

  describe "#to_hash" do
    subject { described_class.new(post, model) }

    it "returns its attributes and their values in a hash" do
      subject.to_hash.should == {
        'sprig_id'  => post.id,
        'title'     => 'Such Title',
        'content'   => 'Very Content',
        'published' => true,
        'poster_id' => "<%= sprig_record(User, #{user.id}).id %>"
      }
    end

    context "when an association/foreign_key is nil" do
      subject { described_class.new(posterless_post, model) }

      it "does not list a sprig record for the nil association" do
        subject.to_hash.should == {
          'sprig_id'  => posterless_post.id,
          'title'     => 'Wow Title',
          'content'   => 'Much Content',
          'published' => false,
          'poster_id' => nil
        }
      end
    end
  end

  describe "#sprig_id" do
    subject { described_class.new(post, model) }

    its(:sprig_id) { should == post.id }

    context "when an existing seed record has a sprig_id equal to the record's id" do
      before do
        model.stub(:existing_sprig_ids).and_return([post.id])
        model.stub(:generate_sprig_id).and_return(25)
      end

      its(:sprig_id) { should == 25 }
    end
  end
end
