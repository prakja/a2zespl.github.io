class SubjectLeaderBoard < ApplicationRecord
  self.table_name = "SubjectLeaderBoard"
  self.primary_key = "id"

  def accuracy
    100 * self.correctAnswerCount / (self.correctAnswerCount + self.incorrectAnswerCount)
  end

  belongs_to :subject, class_name: "Subject", foreign_key: "subjectId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  scope :paid_students, -> {where(UserCourse.where('"UserCourse"."userId" = "SubjectLeaderBoard"."userId"').limit(1).arel.exists)}
end
