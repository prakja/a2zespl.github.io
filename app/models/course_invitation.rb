class CourseInvitation < ApplicationRecord
   attr_accessor :admin_user
   attr_accessor :skip_callback
   self.table_name = "CourseInvitation"
   has_paper_trail
   before_create :setCreatedTime, :setUpdatedTime
   after_commit :after_create_update_course_invitation, on: [:create, :update]
   before_update :before_update_course_invitation, :setUpdatedTime
   after_validation  :mobileValidate, unless: :skip_callback

   validates_presence_of :course, :displayName, :email, :phone, :role, :expiryAt

   attribute :createdAt, :datetime, default: Time.now
   attribute :updatedAt, :datetime, default: Time.now

   belongs_to :admin_user, class_name: "AdminUser", foreign_key: "admin_user_id", optional: true

   def setCreatedTime
     self.createdAt = Time.now
   end

   def setUpdatedTime
     self.updatedAt = Time.now
   end

   def course_expiry_not_valid
    errors.add(:expiryAt, 'can be set only for 2 days for trial access of any course or link payment row correctly for longer access') if payments.blank? and expiryAt and expiryAt > Time.now + 3.day and admin_user.role == 'sales'
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

   scope :invitation_created_more_than_7days_by_sales, -> {
      where('"CourseInvitation"."admin_user_id" in (?) and "CourseInvitation"."expiryAt" > "CourseInvitation"."createdAt" + interval \'7\' day', AdminUser.sales_role);
   }

   scope :invitations_without_payment, -> {
     where.not(PaymentCourseInvitation.where('"PaymentCourseInvitation"."courseInvitationId" = "CourseInvitation"."id"').exists).where(:createdAt => (Time.now - 7.day)..Time.now);
   }
   scope :invitations_expiring_by_tomorrow, -> {
     where.not(PaymentCourseInvitation.where('"PaymentCourseInvitation"."courseInvitationId" = "CourseInvitation"."id"').exists).where(:createdAt => (Time.now - 7.day)..Time.now, :expiryAt => (Time.now - 2.day)..Time.now);
   }
   scope :my_invitations_expiring_soon, ->(admin_user) {
     where.not(PaymentCourseInvitation.where('"PaymentCourseInvitation"."courseInvitationId" = "CourseInvitation"."id"').exists).where(PaperTrail::Version.where('"item_id" = "CourseInvitation"."id" and "whodunnit" = ? and "item_type" = ? and "event" = ?', admin_user, 'CourseInvitation', 'create').exists).where(:createdAt => (Time.now - 7.day)..Time.now);
   }
   scope :my_invitations_expiring_by_tomorrow, ->(admin_user) {
     where.not(PaymentCourseInvitation.where('"PaymentCourseInvitation"."courseInvitationId" = "CourseInvitation"."id"').exists).where(PaperTrail::Version.where('"item_id" = "CourseInvitation"."id" and "whodunnit" = ? and "item_type" = ? and "event" = ?', admin_user, 'CourseInvitation', 'create').exists).where(:createdAt => (Time.now - 2.day)..Time.now);
   }
   has_many :courseInvitationPayments, foreign_key: :courseInvitationId, class_name: 'PaymentCourseInvitation'
   has_many :payments, through: :courseInvitationPayments
   belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: true
end
