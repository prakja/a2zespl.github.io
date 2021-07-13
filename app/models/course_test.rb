class CourseTest < ApplicationRecord
  self.table_name = "CourseTest"
  belongs_to :course, class_name: "Course", foreign_key: "courseId", optional: true 
  belongs_to :test, class_name: "Test", foreign_key: "testId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
