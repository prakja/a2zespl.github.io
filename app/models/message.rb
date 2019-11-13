class Message < ApplicationRecord
  self.table_name = "Message"
  self.inheritance_column = "QWERTY"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :group, class_name: "Group", foreign_key: "groupId"
end
