class SubTopic < ApplicationRecord
  self.table_name = "SubTopic"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  has_many :subTopicQuestions, -> {where(assetType: 'SubTopic', deleted: false, ownerType: "Question")}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :questions, through: :subTopicQuestions
  # has_many :subTopicQuestions, {where(assetType: 'Question', deleted: false)}, foreign_key: :ownerId, class_name: 'TopicAsset'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  attribute :deleted, :boolean, default: false

  has_many :subTopicVideos, -> {where(assetType: 'SubTopic', deleted: false, ownerType: "Video")}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :videos, through: :subTopicVideos

  def self.distinct_name
    SubTopic.connection.select_all("select \"name\", \"id\" from \"SubTopic\"").pluck("name", "id")
  end
  
end