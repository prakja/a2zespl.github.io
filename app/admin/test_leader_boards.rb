ActiveAdmin.register TestLeaderBoard do
  remove_filter :test, :user, :test_attempt
  preserve_default_filters!
  scope :paid_students
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"
end
