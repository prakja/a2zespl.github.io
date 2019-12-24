ActiveAdmin.register UserTodo do
  remove_filter :userId, :topiId, :user, :topic, :subjectId, :subject

  filter :userId_eq, as: :number, label: "User ID"
  filter :user_email, as: :string, label: "User Email"
  filter :user_phone, as: :string, label: "User Phone"

  scope :last_7_days
  scope :last_3_days
  scope :today
  scope :tomorrow

end
