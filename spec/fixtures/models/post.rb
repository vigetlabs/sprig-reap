class Post < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  has_many :votes, :as => :votable

  has_and_belongs_to_many :tags

  def title
    WrappedAttribute.new(self[:title])
  end

  private

  WrappedAttribute = Struct.new(:value)
end
