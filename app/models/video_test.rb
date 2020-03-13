class VideoTest < ApplicationRecord
  self.table_name = "VideoTest"
  belongs_to :video, class_name: "Video", foreign_key: "videoId", optional: true
  belongs_to :test, class_name: "Test", foreign_key: "testId", optional: true

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
