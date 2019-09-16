ActiveAdmin.register UserAction do
  remove_filter :user
  scope :free_users

  index do
    id_column
    column :user
    column :count
    actions
  end

  filter :user_id_eq, as: :number, label: "User ID"
  preserve_default_filters!

end
