class Doubt < ApplicationRecord
  self.table_name = "Doubt"
  has_paper_trail
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  has_many :answers, foreign_key: "doubtId", class_name: "DoubtAnswer"
  belongs_to :question, class_name: "Question", foreign_key: "questionId", counter_cache: true, optional: true
  has_one :doubt_admin, class_name: "DoubtAdmin", foreign_key: "doubtId"
  has_one :admin_user, through: :doubt_admin
  belongs_to :user_doubt_stat, class_name: "UserDoubtStat", foreign_key: "userId"

  scope :my_doubts, -> (admin_id) {
    joins(:doubt_admin => :admin_user).where(doubt_admin: {admin_users: {id: admin_id}})
    #joins(topic:  { subjects: :course }).where(topic: {subjects: { Course: {id: course_id}, id: subject_id }})
  }

  scope :course_name, ->(course_id) {
    joins(:topic => :subjects).where(topic: {Subject: {courseId: course_id}})
  }

  scope :image_doubts, -> {
    where('"content" like \'%img%amazonaws%\' and length(regexp_replace("content", \'<img.*?/>\', \'\')) <= 100').or(where('"imgUrl" is not null')).order('"id" DESC');
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
  scope :ignore_old_doubt, ->(ignore) {
    if ignore == "yes"
      ## TODO: fix this later..for now adding this to bring down doubt count increase due to changes to include mini question bank and 100Q question bank
      return where('"Doubt"."createdAt" > current_timestamp - INTERVAL \'2 week\'');
      #return where('"Doubt"."createdAt" > current_timestamp - INTERVAL \'3 Months\'');
    end
  }
  scope :solved, ->(solved) {
    if solved == "yes"
      # where(DoubtAnswer.where('"DoubtAnswer"."doubtId" = "Doubt"."id" and "DoubtAnswer"."userId" != "Doubt"."userId"').exists).or(where.not(teacherReply: nil))
      where.not('"doubtSolved" is false and ((NOT EXISTS (SELECT "id" from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id")) OR ((SELECT MAX("id") from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id") = (SELECT MAX("id") from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id" and "Doubt"."userId" = "DoubtAnswer"."userId" and "createdAt" > current_date - interval \'3 day\')))')
    else
      # possible arel deprecation fix https://medium.com/rubyinside/active-records-queries-tricks-2546181a98dd (Tip #3)
      where('"doubtSolved" is false and ((NOT EXISTS (SELECT "id" from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id")) OR ((SELECT MAX("id") from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id") = (SELECT MAX("id") from "DoubtAnswer" where "DoubtAnswer"."doubtId" = "Doubt"."id" and "Doubt"."userId" = "DoubtAnswer"."userId" and "createdAt" > current_date - interval \'3 day\')))')
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

  scope :three_days_pending, ->() {
      where(createdAt: 3.days.ago..DateTime::Infinity.new)
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

  scope :botany_paid_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([8, 141, 20, 100, 51, 120, 518], 'yes').deleted('no').subject_name([53, 478, 132, 495, 390, 222, 447, 983, 990, 1152]).distinct}
  scope :chemistry_paid_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([8, 141, 19, 100, 51, 518], 'yes').deleted('no').subject_name([54, 477, 129, 494, 391, 229, 169, 984, 987, 991, 1153]).distinct}
  scope :physics_paid_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([8, 141, 18, 100, 51, 518], 'yes').deleted('no').subject_name([55, 476, 126, 493, 392, 232, 170, 985, 988, 992, 1154]).distinct}
  scope :zoology_paid_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([8, 141, 20, 100, 51, 120, 518], 'yes').deleted('no').subject_name([56, 479, 135, 496, 393, 234, 448, 986, 989, 1155]).distinct}
  scope :masterclass_paid_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([253, 254, 255], 'yes').deleted('no').subject_name([627, 628, 629, 630]).distinct}
  scope :all_masterclass_paid_student_doubts, -> {paid([253, 254, 255], 'yes').deleted('no').subject_name([627, 628, 629, 630]).distinct}
  scope :concept_building_student_doubts, -> {ignore_old_doubt("yes").solved('no').paid([617], 'yes').deleted('no').subject_name([1049]).distinct}

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
    [:subject_name, :solved, :paid, :student_name, :student_email, :student_phone, :course_name]
  end

  def imgUrl
    return nil if self.read_attribute(:imgUrl).blank?
    return self.read_attribute(:imgUrl) if self.read_attribute(:imgUrl).include? "http"
    return "https://www.neetprep.com" + self.read_attribute(:imgUrl)
  end

end
