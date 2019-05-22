class SubTopic < ApplicationRecord
  self.table_name = "SubTopic"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  # has_many :subTopicQuestions, {where(assetType: 'Question', deleted: false)}, foreign_key: :ownerId, class_name: 'TopicAsset'

end
