class Course < ApplicationRecord
  self.table_name = "Course"
  self.inheritance_column = "QWERTY"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime
  has_paper_trail

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  scope :public_courses, -> {where(package: 'neet').order('"id" ASC')}
  has_many :payments, class_name: "Payment", foreign_key: "paymentForId"
  has_many :courseInvitations, class_name: "CourseInvitation", foreign_key: "courseId"
  has_many :courseCourseTests, foreign_key: :courseId, class_name: 'CourseTest'
  has_many :tests, through: :courseCourseTests
  has_many :subjects, class_name: "Subject", foreign_key: "courseId"
end
