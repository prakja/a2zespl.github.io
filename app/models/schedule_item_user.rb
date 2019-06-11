class ScheduleItemUser < ApplicationRecord
  self.table_name = "ScheduleItemUser"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :scheduleItem, class_name: "ScheduleItem", foreign_key: "scheduleItemId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
end
