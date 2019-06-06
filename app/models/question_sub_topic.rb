class QuestionSubTopic < ApplicationRecord
  self.table_name = "QuestionSubTopic"
  belongs_to :question, foreign_key: 'questionId'
  belongs_to :subTopic, foreign_key: 'subTopicId', class_name: 'SubTopic'
end
