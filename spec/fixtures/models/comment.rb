class Comment < ActiveRecord::Base
  belongs_to :post

  validates :post, :presence => true

  has_many :votes, :as => :votable
end
