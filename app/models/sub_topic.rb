class SubTopic < ApplicationRecord
  self.table_name = "SubTopic"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  has_many :subTopicQuestions, -> {where(assetType: 'SubTopic', deleted: false, ownerType: "Question")}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :questions, through: :subTopicQuestions

  def self.distinct_name
    SubTopic.connection.select_all("select \"name\", \"id\" from \"SubTopic\"").pluck("name", "id")
  end
  
end