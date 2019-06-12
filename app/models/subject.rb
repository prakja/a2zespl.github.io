class Subject < ApplicationRecord
  has_paper_trail
  
  self.table_name = "Subject"
  scope :neetprep_course, -> {where(courseId:  8)}
  belongs_to :course, foreign_key: 'courseId', class_name: 'Course'

  has_many :subjectTopics, -> {where(deleted: false)}, foreign_key: :subjectId, class_name: 'SubjectChapter'
  has_many :topics, through: :subjectTopics
end
