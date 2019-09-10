ActiveAdmin.register Answer do
  remove_filter :versions, :user, :question, :testAttempt
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"
  filter :questionId_eq, as: :number, label: "Question ID"
  filter :testAttemptId_eq, as: :number, label: "TestAttempt ID"

  scope :correct_answers
  scope :incorrect_answers

  index do
    id_column
    column (:question) {|answer| raw(answer.question.question)}
    column (:correct) {|answer| answer.correct ? 'yes' : 'no'}
    column (:userAnswer) {|answer| answer.question.options[answer.userAnswer]}
    column (:correctOption) {|answer| answer.question.options[answer.question.correctOptionIndex]}
  end
end
