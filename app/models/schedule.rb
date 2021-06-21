class Schedule < ApplicationRecord
  self.table_name = "Schedule"
  
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  has_many :scheduleItems, class_name: "ScheduleItem", foreign_key: "scheduleId"
  scope :active, ->() {
    where(isActive: true)
  }
end
