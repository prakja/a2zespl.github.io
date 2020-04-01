class CourseOffer < ApplicationRecord
  self.table_name = "CourseOffer"

  nilify_blanks

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :admin_user, class_name: "AdminUser", foreign_key: "admin_user_id", optional: true
  belongs_to :course, class_name: "Course", foreign_key: "courseId"

  scope :user_via_email, -> {
    joins(:user).where('"User"."email" = "email"')
  }

  scope :user_via_phone, -> {
    joins(:user).where('"User"."phone" = "phone"')
  }
end
