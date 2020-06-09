class UserProfile < ApplicationRecord
  self.table_name = "UserProfile"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  belongs_to :user, class_name: "User", foreign_key: "userId"

end
