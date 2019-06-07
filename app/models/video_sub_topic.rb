class VideoSubTopic < ApplicationRecord
  self.table_name = "VideoSubTopic"
  belongs_to :video, foreign_key: 'videoId'
  belongs_to :subTopic, foreign_key: 'subTopicId', class_name: 'SubTopic'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
