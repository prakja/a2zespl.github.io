class TargetChapter < ApplicationRecord
  self.table_name = "TargetChapter"

  belongs_to :target, class_name: "Target", foreign_key: "targetId"
  belongs_to :chapter, class_name: "Topic", foreign_key: :chapterId
end
