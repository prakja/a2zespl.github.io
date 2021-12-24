class UserChatAuthToken < ApplicationRecord
  self.table_name = "UserChatAuthToken"

  validates :userId, presence: true
  validates :authToken, presence: true

  belongs_to :user, class_name: "User", foreign_key: "userId"
end
