class SubjectChapter < ApplicationRecord
  self.table_name = "SubjectChapter"
  belongs_to :subject, class_name: "Subject", foreign_key: 'subjectId', optional: true
  belongs_to :topic, class_name: "Topic", foreign_key: 'chapterId'

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
