class Doubt < ApplicationRecord
  self.table_name = "Doubt"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  has_many :answers, foreign_key: "doubtId", class_name: "DoubtAnswer"
  belongs_to :question, class_name: "Question", foreign_key: "questionId", counter_cache: true, optional: true
  has_one :doubt_admin, class_name: "DoubtAdmin", foreign_key: "doubtId"
  has_one :admin_user, through: :doubt_admin

  scope :my_doubts, -> (admin_id) {
    joins(:doubt_admin => :admin_user).where(doubt_admin: {admin_users: {id: admin_id}})
    #joins(topic:  { subjects: :course }).where(topic: {subjects: { Course: {id: course_id}, id: subject_id }})
  }

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
  scope :paid, ->(course_ids, paid) {
    if paid == "yes"
      where(UserCourse.where('"UserCourse"."userId" = "Doubt"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').where(courseId: course_ids).exists)
    else
      where.not(UserCourse.where('"UserCourse"."userId" = "Doubt"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').where(courseId: course_ids).exists)
    end
  }

  scope :deleted, ->(deleted) {
    if deleted == "yes"
      where(deleted: true)
    else
      where(deleted: false)
    end
  }

  scope :two_days_pending, ->(two_days_pending) {
    if two_days_pending == "yes"
      where(createdAt: 2.days.ago..DateTime::Infinity.new)
    end
  }

  scope :five_days_pending, ->(five_days_pending) {
    if five_days_pending == "yes"
      where(createdAt: 5.days.ago..DateTime::Infinity.new)
    end
  }

  scope :seven_days_pending, ->(seven_days_pending) {
    if seven_days_pending == "yes"
      where(createdAt: 7.days.ago..DateTime::Infinity.new)
    end
  }

  scope :botany_paid_student_doubts, -> {solved('no').paid([8, 141, 20], 'yes').deleted('no').subject_name([53, 478, 132]).distinct}
  scope :chemistry_paid_student_doubts, -> {solved('no').paid([8, 141, 19], 'yes').deleted('no').subject_name([54, 477, 129]).distinct}
  scope :physics_paid_student_doubts, -> {solved('no').paid([8, 141, 18], 'yes').deleted('no').subject_name([55, 476, 126]).distinct}
  scope :zoology_paid_student_doubts, -> {solved('no').paid([8, 141, 20], 'yes').deleted('no').subject_name([56, 479, 135]).distinct}

  scope :paid_student_doubts, -> {paid([8, 141, 20, 19, 18, 20], 'yes').deleted('no').subject_name([53, 54, 55, 56, 476, 477, 478, 479, 126, 129, 132, 135]).distinct}

  # scope :assigined_to_me, -> {my_doubts(current_admin_user.id)}

  scope :botany_paid_student_doubts_two_days, -> {botany_paid_student_doubts().two_days_pending('yes')}
  scope :botany_paid_student_doubts_five_days, -> {botany_paid_student_doubts().five_days_pending('yes')}
  scope :botany_paid_student_doubts_seven_days, -> {botany_paid_student_doubts().seven_days_pending('yes')}

  scope :physics_paid_student_doubts_two_days, -> {physics_paid_student_doubts().two_days_pending('yes')}
  scope :physics_paid_student_doubts_five_days, -> {physics_paid_student_doubts().five_days_pending('yes')}
  scope :physics_paid_student_doubts_seven_days, -> {physics_paid_student_doubts().seven_days_pending('yes')}

  scope :chemistry_paid_student_doubts_two_days, -> {chemistry_paid_student_doubts().two_days_pending('yes')}
  scope :chemistry_paid_student_doubts_five_days, -> {chemistry_paid_student_doubts().five_days_pending('yes')}
  scope :chemistry_paid_student_doubts_seven_days, -> {chemistry_paid_student_doubts().seven_days_pending('yes')}

  scope :zoology_paid_student_doubts_two_days, -> {zoology_paid_student_doubts().two_days_pending('yes')}
  scope :zoology_paid_student_doubts_five_days, -> {zoology_paid_student_doubts().five_days_pending('yes')}
  scope :zoology_paid_student_doubts_seven_days, -> {zoology_paid_student_doubts().seven_days_pending('yes')}

  def self.ransackable_scopes(_auth_object = nil)
    [:subject_name, :solved, :paid, :student_name, :student_email, :student_phone]
  end

  def imgUrl
    return nil if self.read_attribute(:imgUrl).blank?
    return self.read_attribute(:imgUrl) if self.read_attribute(:imgUrl).include? "http"
    return "https://www.neetprep.com" + self.read_attribute(:imgUrl)
  end

end
