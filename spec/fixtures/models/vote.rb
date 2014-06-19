class Vote < ActiveRecord::Base
  belongs_to :votable, :polymorphic => true

  validates :votable_type, :votable_id, :presence => true
end
