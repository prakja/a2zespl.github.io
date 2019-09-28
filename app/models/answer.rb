class Answer < ApplicationRecord
  self.table_name = "Answer"
  belongs_to :user, foreign_key: "userId", class_name: "User"
  belongs_to :question, foreign_key: "questionId", class_name: "Question"
  belongs_to :testAttempt, foreign_key: "testAttemptId", class_name: "TestAttempt", optional: true

  def correct
    return self.userAnswer == self.question.correctOptionIndex
  end

  scope :correct_answers, -> {
    joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"')
  }

  scope :incorrect_answers, -> {
    joins(:question).where('"Question"."correctOptionIndex" != "userAnswer"')
  }

  scope :paid, ->(paid, start_date, end_date) {
    if paid == "yes"
      if start_date != nil and end_date != nil
        where(UserCourse.where('"UserCourse"."userId" = "Answer"."userId" AND "UserCourse"."createdAt" <= ? and "UserCourse"."createdAt" >= ?', "#{start_date}", "#{end_date}").exists)
      else
        # currently paid students
        where(UserCourse.where('"UserCourse"."userId" = "Answer"."userId" AND "UserCourse"."expiryAt" >= current_timestamp').exists)
      end
    else
      where.not(UserCourse.where('"UserCourse"."userId" = "Answer"."userId" AND "UserCourse"."createdAt" <= ? and "UserCourse"."createdAt" >= ?', "#{start_date}", "#{end_date}").exists)
    end
  }

  scope :paid_users_answers, -> {paid("yes", nil, nil)}

end
