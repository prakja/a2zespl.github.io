class ChapterVideo < ApplicationRecord
  self.table_name = "ChapterVideo"
  belongs_to :video, foreign_key: 'videoId'
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic'
end
