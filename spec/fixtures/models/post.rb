class Post < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  has_many :votes, :as => :votable
end
