class Doubt < ApplicationRecord
  self.table_name = "Doubt"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  has_many :answers, foreign_key: "doubtId", class_name: "DoubtAnswer"
  scope :subject_doubts, ->(subject_id) {
    joins(:topic => :subjects).where(topic: {Subject: {id: subject_id}})
  }
  scope :solved, ->(solved) {
    if solved == "yes"
      where(DoubtAnswer.where('"DoubtAnswer"."doubtId" = "Doubt"."id" and "DoubtAnswer"."userId" != "Doubt"."userId"').exists).or(where.not(teacherReply: nil))
    else
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
  scope :botany_paid_student_doubts, -> {solved('no').paid('yes').subject_doubts(53)}
  scope :chemistry_paid_student_doubts, -> {solved('no').paid('yes').subject_doubts(54)}
  scope :physics_paid_student_doubts, -> {solved('no').paid('yes').subject_doubts(55)}
  scope :zoology_paid_student_doubts, -> {solved('no').paid('yes').subject_doubts(56)}
  
  def self.ransackable_scopes(_auth_object = nil)
    [:subject_doubts, :solved, :paid]
  end

end
