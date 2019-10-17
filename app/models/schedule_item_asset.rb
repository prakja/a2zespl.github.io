class ScheduleItemAsset < ApplicationRecord
  self.table_name = "ScheduleItemAsset"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :scheduleItem, foreign_key: "ScheduleItem_id", class_name: "ScheduleItem"
end
