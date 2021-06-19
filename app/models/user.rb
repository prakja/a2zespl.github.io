class User < ApplicationRecord
 self.table_name = "User"
 before_save :swap_unique_email_phone
 nilify_blanks

 has_many :schedule_item_users, class_name: "ScheduleItemUser", foreign_key: "userId"
 has_one :user_profile, class_name: "UserProfile", foreign_key: "userId"
 has_many :customer_supports, class_name: "CustomerSupport", foreign_key: "userId"

 has_many :doubts, class_name: "Doubt", foreign_key: "userId"
 has_many :user_todos, class_name: "UserTodo", foreign_key: "userId"
 has_many :test_attempts, class_name: "TestAttempt", foreign_key: "userId"
 has_one :user_profile_analytics, class_name: "UserProfileAnalytic", foreign_key: "userId"
 has_one :user_action, foreign_key: "userId"
 has_many :user_video_stats, class_name: "UserVideoStat", foreign_key: "userId"
 has_one :common_rank, class_name: "CommonLeaderBoard", foreign_key: "userId"
 has_many :subject_rank, class_name: "SubjectLeaderBoard", foreign_key: "userId"
 has_many :studentCoches, foreign_key: "studentId", class_name: 'StudentCoach'
#  has_many :coaches, through: :studentCoches

 has_many :answers, class_name: "Answer", foreign_key: "userId"

 has_many :user_courses, class_name: "UserCourse", foreign_key: "userId"
 has_many :payments, class_name: "Payment", foreign_key: "userId"

 has_many :userFlashCards, class_name: "UserFlashCard", foreign_key: "userId", dependent: :destroy
 has_many :flash_cards, through: :userFlashCards

 has_many :results, class_name: "UserResult", foreign_key: "userId"

 scope :student_name, ->(name) {
   joins(:user_profile).where('"UserProfile"."displayName" ILIKE ?', "%#{name}%")
 }
 scope :student_email, ->(email) {
  User.joins('FULL JOIN "UserProfile" ON "UserProfile"."userId" = "User"."id"').where('"UserProfile"."email" ILIKE ? or "User"."email" ILIKE ?', "%#{email}%", "%#{email}%")
 }
 scope :student_phone, ->(phone) {
  User.joins('FULL JOIN "UserProfile" ON "UserProfile"."userId" = "User"."id"').where('"UserProfile"."phone" ILIKE ? or "User"."phone" ILIKE ?', "%#{phone}%", "%#{phone}%")
 }

 has_paper_trail
 # scope :free_users, -> {
#   where.not(UserCourse.where('"UserCourse"."userId" = "User"."id"').exists)
# }
# scope :paid_users, -> {
 #   joins(:user_courses).where('"UserCourse"."expiryAt" >= CURRENT_TIMESTAMP')
 # }
 
 def swap_unique_email_phone
   if self.email_changed?
     swap_unique("email")
   end
   if self.phone_changed?
     swap_unique("phone")
   end
 end

 def swap_unique(field_name)
   if self[(field_name).to_sym].present?
     User.where("\"#{field_name}\" = '#{self[(field_name).to_sym]}' and \"id\" != #{self.id}").update_all(field_name.to_sym => "\##{self.id}\##{self.send(field_name + "_was")}")
   end
 end

 def self.ransackable_scopes(_auth_object = nil)
   [:student_name, :student_email, :student_phone]
 end

 def name
   if not self.user_profile.blank? and not self.user_profile.displayName.blank?
     return self.user_profile.displayName
   else
     return 'NEET student'
   end
 end
end
