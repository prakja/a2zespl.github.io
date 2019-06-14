class CourseInvitation < ApplicationRecord
   self.table_name = "CourseInvitation"

   after_commit :after_create_update_course_invitation, on: [:create, :update]

   validates_presence_of :course, :displayName, :email, :phone, :role, :expiryAt

   def self.recent_course_invitations
     CourseInvitation.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:id)
   end

   def after_create_update_course_invitation
     if self.course.blank? or self.displayName.blank? or self.email.blank? or self.phone.blank? or self.role.blank? or self.payments.blank? or self.expiryAt.blank?
       return
     end

     HTTParty.post(
       Rails.configuration.node_site_url + "api/v1/webhook/afterCreateUpdateCourseInvitation",
        body: {
          id: self.id,
     })
   end

   attribute :createdAt, :datetime, default: Time.now
   attribute :updatedAt, :datetime, default: Time.now
   has_many :courseInvitationPayments, foreign_key: :courseInvitationId, class_name: 'PaymentCourseInvitation'
   has_many :payments, through: :courseInvitationPayments
   belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: true
end
