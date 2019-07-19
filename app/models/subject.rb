class Subject < ApplicationRecord
  has_paper_trail

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  self.table_name = "Subject"
  scope :neetprep_course, -> {where(courseId:  8)}
  belongs_to :course, foreign_key: 'courseId', class_name: 'Course'

  has_many :subjectTopics, -> {where(deleted: false)}, foreign_key: :subjectId, class_name: 'SubjectChapter'
  has_many :topics, through: :subjectTopics
end
