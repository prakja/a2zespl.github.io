class QuestionSubTopic < ApplicationRecord
  self.table_name = "QuestionSubTopic"
  belongs_to :question, foreign_key: 'questionId', class_name: 'Question'
  belongs_to :subTopic, foreign_key: 'subTopicId', class_name: 'SubTopic'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
