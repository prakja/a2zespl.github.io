class CourseInvitation < ApplicationRecord
   self.table_name = "CourseInvitation"
   has_paper_trail
   after_commit :after_create_update_course_invitation, on: [:create, :update]
   before_update :before_update_course_invitation
   after_validation :course_expiry_not_valid, :mobileValidate

   validates_presence_of :course, :displayName, :email, :phone, :role, :expiryAt

   def course_expiry_not_valid
    errors.add(:expiryAt, 'can set only for 7 days when payments are not linked') if payments.blank? and expiryAt and expiryAt > Time.now + 7.day
   end

   def mobileValidate
     errors.add(:phone, 'length can not be less than 10') if phone.length < 10
   end

   def self.recent_course_invitations
     CourseInvitation.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:id)
   end

   def before_update_course_invitation
     HTTParty.post(
       Rails.configuration.node_site_url + "api/v1/webhook/beforeUpdateCourseInvitation",
        body: {
          id: self.id,
          phone: self.phone,
          email: self.email
     })
   end

   def after_create_update_course_invitation
     if self.course.blank? or self.displayName.blank? or self.email.blank? or self.phone.blank? or self.role.blank? or self.expiryAt.blank?
       return
     end

     HTTParty.post(
       Rails.configuration.node_site_url + "api/v1/webhook/afterCreateUpdateCourseInvitation",
        body: {
          id: self.id,
     })
   end

   scope :invitations_without_payment_last_7_days, -> {
     where.not(PaymentCourseInvitation.where('"PaymentCourseInvitation"."courseInvitationId" = "CourseInvitation"."id"').exists).where(:createdAt => (Time.now - 7.day)..Time.now);
   }
   attribute :createdAt, :datetime, default: Time.now
   attribute :updatedAt, :datetime, default: Time.now
   has_many :courseInvitationPayments, foreign_key: :courseInvitationId, class_name: 'PaymentCourseInvitation'
   has_many :payments, through: :courseInvitationPayments
   belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: true
end
