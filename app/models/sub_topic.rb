class SubTopic < ApplicationRecord
  has_paper_trail

  self.table_name = "SubTopic"
  scope :topic_sub_topics, lambda {|topicIds| where(topicId: topicIds)}
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  has_many :subTopicQuestions, -> {where(assetType: 'SubTopic', deleted: false, ownerType: "Question")}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :questions, through: :subTopicQuestions
  has_many :subTopicQuestions, foreign_key: :subTopicId, class_name: 'QuestionSubTopic'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  attribute :deleted, :boolean, default: false

  has_many :subTopicVideos, foreign_key: :subTopicId, class_name: 'VideoSubTopic'
  has_many :videos, through: :subTopicVideos

  scope :botany, -> {joins(:topic => :subject).where(topic: {Subject: {id:  53}})}
  scope :chemistry, -> {joins(:topic => :subject).where(topic: {Subject: {id:  54}})}
  scope :physics, -> {joins(:topic => :subject).where(topic: {Subject: {id:  55}})}
  scope :zoology, -> {joins(:topic => :subject).where(topic: {Subject: {id:  56}})}

  def self.distinct_name
    SubTopic.connection.select_all("select \"SubTopic\".\"name\", \"SubTopic\".\"id\", \"Topic\".\"name\" as \"topicName\" from \"SubTopic\", \"Topic\" where \"SubTopic\".\"topicId\" = \"Topic\".\"id\"").pluck("name", "id", "topicName").map{|sub_topic_name, id, topic_name| [topic_name + " - " + sub_topic_name, id]}
  end

end
