class Course < ApplicationRecord
  self.table_name = "Course"
  self.inheritance_column = "QWERTY"
  scope :public_courses, -> {where(package: 'neet').order('"id" ASC')}
  has_many :payments, class_name: "Payment", foreign_key: "paymentForId"
  has_many :courseInvitations, class_name: "CourseInvitation", foreign_key: "courseId"
  has_many :courseCourseTests, foreign_key: :courseId, class_name: 'CourseTest'
  has_many :tests, through: :courseCourseTests
end
