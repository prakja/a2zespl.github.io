ActiveAdmin.register Answer do
  remove_filter :versions, :user, :question, :testAttempt, :questionAnalytic, :incorrectAnswerReason, :incorrectAnswerOther
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"
  filter :questionId_eq, as: :number, label: "Question ID"
  filter :testAttemptId_eq, as: :number, label: "TestAttempt ID"
  filter :questionAnalytic_difficultyLevel_eq, as: :select, collection: ["easy", "medium", "difficult"], label: "Difficulty"
  filter :incorrectAnswerReason_present, as: :boolean, label: "Incorrect Answer Reason Present"
  filter :incorrectAnswerReason_eq, as: :boolean, collection: ["1", "2"], label: "Incorrect Answer Reason"
  filter :incorrectAnswerOther_present, as: :boolean, label: "Incorrect Answer Other Present"

  scope :correct_answers, show_count: false
  scope :incorrect_answers, show_count: false
  scope :incorrect_physics_answers, show_count: false
  scope :correct_physics_answers, show_count: false
  scope :incorrect_chemistry_answers, show_count: false
  scope :correct_chemistry_answers, show_count: false
  scope :incorrect_botany_answers, show_count: false
  scope :correct_botany_answers, show_count: false
  scope :incorrect_zoology_answers, show_count: false
  scope :correct_zoology_answers, show_count: false
  scope :incorrect_test_answers, show_count: false

  controller do
    def scoped_collection
      super.left_outer_joins(:questionAnalytic, :question).select('"Answer".*, "QuestionAnalytics"."correctPercentage" as correct_percentage')
    end
  end

  index do
    id_column
    column (:question) {|answer| raw(answer.question&.question)}
    column (:correct) {|answer| answer.correct ? 'yes' : 'no'}
    column (:userAnswer) {|answer| answer.question&.options[answer.userAnswer]}
    column (:correctOption) {|answer| answer.question&.options[answer.question&.correctOptionIndex]}
    column "difficulty Level" do |answer|
     answer.questionAnalytic.difficultyLevel
    end
    column :correct_percentage, :sortable => true
    column :incorrectAnswerReason
    column :incorrectAnswerOther
  end
end
