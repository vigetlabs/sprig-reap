class Post < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  has_many :votes, :as => :votable

  def title
    WrappedAttribute.new(self[:title])
  end

  private

  WrappedAttribute = Struct.new(:value)
end
