class TopicAsset < ApplicationRecord
  before_save :default_values
  def default_values
    self.topicId = 0 if self.topicId.nil?
    self.ownerId = self.topicId if self.ownerType == 'Topic'
  end
  self.table_name = "TopicAsset"
  belongs_to :topic, foreign_key: 'topicId', optional: true
  belongs_to :subTopic, class_name: "SubTopic", foreign_key: "assetId", optional: true
  belongs_to :question, -> {where(deleted: false)}, foreign_key: 'assetId', optional: true
  belongs_to :questionSubTopic, -> {where(deleted: false)}, foreign_key: 'ownerId', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
