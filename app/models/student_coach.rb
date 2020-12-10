class StudentCoach < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "studentId"
  belongs_to :admin_user, class_name: "AdminUser", foreign_key: "coachId"

  validates_presence_of :studentId, :coachId, :role

  scope :my_students, ->(admin_user) {
    where(coachId: admin_user);
  }
end
