ActiveAdmin.register TestLeaderBoard do
  remove_filter :test, :user, :test_attempt
  preserve_default_filters!
  scope :paid_students
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"

  index do
    column :id
    column :rank
    column :user
    column :test
    column :test_attempt
    column :score
    column :correctAnswerCount
    column :incorrectAnswerCount
    column "Time Taken" do |testLeaderBoard|
      raw(((testLeaderBoard.test_attempt.updatedAt - testLeaderBoard.test_attempt.createdAt) / 60).round.to_s + " minutes")
    end
    actions
  end

end
