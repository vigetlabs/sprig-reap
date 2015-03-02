class Post < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  has_many :votes, :as => :votable

  has_and_belongs_to_many :tags

  scope :published,    -> { where(:published => true) }
  scope :with_content, -> { where('content IS NOT NULL') }

  def title
    WrappedAttribute.new(self[:title])
  end

  private

  WrappedAttribute = Struct.new(:value)
end
