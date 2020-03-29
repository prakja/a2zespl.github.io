class VideoQuestion < ApplicationRecord
  self.table_name = "VideoQuestion"
  belongs_to :video, class_name: "Video", foreign_key: "videoId"
  belongs_to :question, class_name: "Question", foreign_key: "questionId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
