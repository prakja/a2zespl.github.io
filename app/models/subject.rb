class Subject < ApplicationRecord
  self.table_name = "Subject"
  scope :neetprep_course, -> {where(courseId:  8)}
  belongs_to :course, foreign_key: 'courseId', class_name: 'Course'
end
