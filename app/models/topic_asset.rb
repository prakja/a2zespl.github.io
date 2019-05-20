class TopicAsset < ApplicationRecord
  self.table_name = "TopicAsset"
  belongs_to :topic, foreign_key: 'topicId'
  belongs_to :question, -> {where(deleted: false)}, foreign_key: 'assetId'
end
