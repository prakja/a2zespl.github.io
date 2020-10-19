class Answer < ApplicationRecord
  self.table_name = "Answer"
  belongs_to :user, foreign_key: "userId", class_name: "User"
  belongs_to :question, foreign_key: "questionId", class_name: "Question"
  belongs_to :testAttempt, foreign_key: "testAttemptId", class_name: "TestAttempt", optional: true
  belongs_to :questionAnalytic, foreign_key: "questionId", class_name: "QuestionAnalytic"

  def correct
    return self.userAnswer == self.question&.correctOptionIndex
  end

  default_scope {joins(:question).where('"Question"."deleted" = false')}

  scope :correct_answers, -> {
    joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"')
  }

  scope :incorrect_answers, -> {
    joins(:question).where('"Question"."correctOptionIndex" != "userAnswer"')
  }

  scope :bio_masterclass_course, -> {
    joins(:question).merge(Question.bio_masterclass_course)
  }

  scope :incorrect_physics_answers, -> {
    Answer.incorrect_answers.merge(Question.physics_mcqs)
  }

  scope :correct_physics_answers, -> {
    Answer.correct_answers.merge(Question.physics_mcqs)
  }

  scope :incorrect_chemistry_answers, -> {
    Answer.incorrect_answers.merge(Question.chemistry_mcqs)
  }

  scope :correct_chemistry_answers, -> {
    Answer.correct_answers.merge(Question.chemistry_mcqs)
  }

  scope :incorrect_botany_answers, -> {
    Answer.incorrect_answers.merge(Question.botany_mcqs)
  }

  scope :correct_botany_answers, -> {
    Answer.correct_answers.merge(Question.botany_mcqs)
  }

  scope :incorrect_zoology_answers, -> {
    Answer.incorrect_answers.merge(Question.zoology_mcqs)
  }

  scope :correct_zoology_answers, -> {
    Answer.correct_answers.merge(Question.zoology_mcqs)
  }

  scope :correct_test_answers, -> {
    Answer.correct_answers.merge(Question.test_questions)
  }

  scope :incorrect_test_answers, -> {
    Answer.incorrect_answers.merge(Question.test_questions)
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
