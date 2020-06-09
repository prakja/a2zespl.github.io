class ActiveFlashCardChapter < ApplicationRecord
  self.table_name = "ActiveFlashCardChapter"
  belongs_to :topic, class_name: "Topic", foreign_key: "chapterId"
end
