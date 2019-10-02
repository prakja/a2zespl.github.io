ActiveAdmin.register Answer do
  remove_filter :versions, :user, :question, :testAttempt
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"
  filter :questionId_eq, as: :number, label: "Question ID"
  filter :testAttemptId_eq, as: :number, label: "TestAttempt ID"

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

  index do
    id_column
    column (:question) {|answer| raw(answer.question.question)}
    column (:correct) {|answer| answer.correct ? 'yes' : 'no'}
    column (:userAnswer) {|answer| answer.question.options[answer.userAnswer]}
    column (:correctOption) {|answer| answer.question.options[answer.question.correctOptionIndex]}
  end
end
