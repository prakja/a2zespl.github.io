class UserCourse < ApplicationRecord
 self.table_name = "UserCourse"
 belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: false
 belongs_to :courseInvitation, foreign_key: "invitationId", class_name: "CourseInvitation", optional: false
end
