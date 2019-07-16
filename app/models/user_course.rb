class UserCourse < ApplicationRecord
 self.table_name = "UserCourse"
 has_paper_trail
 belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: false
 belongs_to :invitation, foreign_key: "invitationId", class_name: "CourseInvitation"
 # belongs_to :courseInvitation, foreign_key: "invitationId", class_name: "CourseInvitation", optional: true
 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now
end
