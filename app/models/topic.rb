class Topic < ApplicationRecord
  self.table_name = "Topic"
  has_many :topicQuestions, -> {where(assetType: 'Question', deleted: false)}, foreign_key: :topicId, class_name: 'TopicAsset'
  has_many :questions, through: :topicQuestions
end
