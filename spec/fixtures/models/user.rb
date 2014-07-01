require './spec/fixtures/uploaders/avatar_uploader'

class User < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true

  mount_uploader :avatar, AvatarUploader
end
