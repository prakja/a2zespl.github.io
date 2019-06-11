class ScheduleItem < ApplicationRecord
  self.table_name = "ScheduleItem"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :schedule, class_name: "Schedule", foreign_key: "scheduleId"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  has_many :scheduleItemUsers, class_name: "ScheduleItemUser", foreign_key: "scheduleItemId"
end
