class Doubt < ApplicationRecord
  self.table_name = "Doubt"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  has_many :answers, foreign_key: "doubtId", class_name: "DoubtAnswer"
  scope :subject_name, ->(subject_id) {
    joins(:topic => :subjects).where(topic: {Subject: {id: subject_id}})
  }
  scope :student_name, ->(name) {
    joins(:user => :user_profile).where('"UserProfile"."displayName" ILIKE ?', "%#{name}%")
  }
  scope :student_email, ->(email) {
    joins(:user => :user_profile).where('"UserProfile"."email" ILIKE ? or "User"."email" ILIKE ?', "%#{email}%", "%#{email}%")
  }
  scope :student_phone, ->(phone) {
    joins(:user => :user_profile).where('"UserProfile"."phone" ILIKE ? or "User"."phone" ILIKE ?', "%#{phone}%", "%#{phone}%")
  }
  scope :solved, ->(solved) {
    if solved == "yes"
      where(DoubtAnswer.where('"DoubtAnswer"."doubtId" = "Doubt"."id" and "DoubtAnswer"."userId" != "Doubt"."userId"').exists).or(where.not(teacherReply: nil))
    else
      # possible arel deprecation fix https://medium.com/rubyinside/active-records-queries-tricks-2546181a98dd (Tip #3)
      where.not(DoubtAnswer.where('"DoubtAnswer"."doubtId" = "Doubt"."id" and "DoubtAnswer"."userId" != "Doubt"."userId"').exists).where(teacherReply: nil)
    end
  }
  scope :paid, ->(paid) {
    if paid == "yes"
      where(UserCourse.where('"UserCourse"."userId" = "Doubt"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').exists)
    else
      where.not(UserCourse.where('"UserCourse"."userId" = "Doubt"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').exists)
    end
  }

  scope :deleted, ->(deleted) {
    if deleted == "yes"
      where(deleted: true)
    else
      where(deleted: false)
    end
  }

  scope :botany_paid_student_doubts, -> {solved('no').paid('yes').deleted('no').subject_name(53)}
  scope :chemistry_paid_student_doubts, -> {solved('no').paid('yes').deleted('no').subject_name(54)}
  scope :physics_paid_student_doubts, -> {solved('no').paid('yes').deleted('no').subject_name(55)}
  scope :zoology_paid_student_doubts, -> {solved('no').paid('yes').deleted('no').subject_name(56)}
  
  def self.ransackable_scopes(_auth_object = nil)
    [:subject_name, :solved, :paid, :student_name, :student_email, :student_phone]
  end

end
