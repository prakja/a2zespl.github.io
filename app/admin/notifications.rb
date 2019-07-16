ActiveAdmin.register Notification do
  remove_filter :user
  filter :userId_eq, as: :number, label: "User ID"
end
