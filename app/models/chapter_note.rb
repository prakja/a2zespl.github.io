class ChapterNote < ApplicationRecord
  self.table_name = "ChapterNote"
  belongs_to :note, foreign_key: 'noteId', optional: true
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
