class Video < ApplicationRecord
  self.table_name = "Video"

  has_many :videoTopics, -> {where(assetType: 'Video', deleted: false, ownerType: 'Topic')}, foreign_key: :assetId, class_name: 'TopicAsset', inverse_of: 'video'
  has_many :topics, through: :videoTopics
  
  has_many :videoSubTopics, -> {where(assetType: 'SubTopic', deleted: false, ownerType: 'Video')}, foreign_key: :ownerId, class_name: 'TopicAsset', inverse_of: 'videoSubTopic'
  has_many :subTopics, through: :videoSubTopics
end
