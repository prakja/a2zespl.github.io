class VideoLink < ApplicationRecord
  self.table_name = "VideoLink"
  belongs_to :video, foreign_key: 'videoId', class_name: 'Video'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  validates_presence_of :name, :time, :videoId
end
