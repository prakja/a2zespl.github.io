class VideoAnnotation < ApplicationRecord
  before_save :default_values
  def default_values
    self.videoTimeMS = self.videoTimeStampInSeconds * 1000 if !self.videoTimeStampInSeconds.nil?
  end
  self.table_name = "VideoAnnotation"
  belongs_to :video, class_name: "Video", foreign_key: :videoId

  belongs_to :note, class_name: "Note", foreign_key: "annotationId", optional: true

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  accepts_nested_attributes_for :note, :allow_destroy => true
end
