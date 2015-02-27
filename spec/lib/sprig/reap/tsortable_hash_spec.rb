require 'spec_helper'

describe Sprig::Reap::TsortableHash do
  describe "#resolve_circular_habtm_dependencies!" do
    subject do
      described_class.new.merge(
        Comment => [Post],
        Post    => [User, Tag],
        Tag     => [Post],
        User    => [],
        Vote    => [Post]
      )
    end

    it "trims out circular dependencies resulting from has-and-belongs-to-many" do
      subject.resolve_circular_habtm_dependencies!
      
      subject.should == {
        Comment => [Post],
        Post    => [User, Tag],
        Tag     => [],
        User    => [],
        Vote    => [Post]
      }
    end
  end
end
