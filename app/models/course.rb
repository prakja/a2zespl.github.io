class Course < ApplicationRecord
  self.table_name = "Course"
  self.inheritance_column = "QWERTY"
  scope :public_courses, -> {where(package: 'neet')}
  has_many :payments, class_name: "Payment", foreign_key: "paymentForId"
  has_many :courseInvitations, class_name: "CourseInvitation", foreign_key: "courseId"

end
