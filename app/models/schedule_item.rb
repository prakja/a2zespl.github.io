class ScheduleItem < ApplicationRecord
  self.table_name = "ScheduleItem"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :schedule, class_name: "Schedule", foreign_key: "scheduleId"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId", optional: true
  has_many :scheduleItemUsers, class_name: "ScheduleItemUser", foreign_key: "scheduleItemId"
  has_many :scheduleItemAssets, class_name: "ScheduleItemAsset", foreign_key: "ScheduleItem_id"

  def self.topper_schedule_items
    ScheduleItem.where(scheduleId: 5).pluck("name", "id")
  end
end
