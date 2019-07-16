ActiveAdmin.register Notification do
  remove_filter :user
  filter :userId_eq, as: :number, label: "User ID"
  preserve_default_filters!

  index do

    id_column
    column :title
    column :user
    column (:body) { |notification| raw(notification.body)  }
    actions
  end
end
