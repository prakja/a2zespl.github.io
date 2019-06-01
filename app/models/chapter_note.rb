class ChapterNote < ApplicationRecord
  self.table_name = "ChapterNote"
  belongs_to :note, foreign_key: 'noteId'
  belongs_to :topic, foreign_key: 'chapterId', :class_name: 'Topic'
end
