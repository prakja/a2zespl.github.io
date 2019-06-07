class ChapterQuestion < ApplicationRecord
  self.table_name = "ChapterQuestion"
  belongs_to :question, foreign_key: 'questionId'
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
