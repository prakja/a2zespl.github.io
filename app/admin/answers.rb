ActiveAdmin.register Answer do
  remove_filter :versions, :user, :question, :testAttempt
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"
  filter :questionId_eq, as: :number, label: "Question ID"
  filter :testAttemptId_eq, as: :number, label: "TestAttempt ID"
end
