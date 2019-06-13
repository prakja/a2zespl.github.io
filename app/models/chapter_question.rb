class ChapterQuestion < ApplicationRecord
  self.table_name = "ChapterQuestion"
  belongs_to :question, foreign_key: 'questionId', optional: true
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
