class Note < ApplicationRecord
 self.table_name = "Note"
 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now

  has_one :video_annotation, class_name: "VideoAnnotation", foreign_key: "annotationId"
  has_one :video, through: :video_annotation
end
