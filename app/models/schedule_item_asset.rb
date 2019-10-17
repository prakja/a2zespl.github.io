class ScheduleItemAsset < ApplicationRecord
  self.table_name = "ScheduleItemAsset"
  
  belongs_to :scheduleItem, foreign_key: "ScheduleItem_id", class_name: "ScheduleItem"
end
