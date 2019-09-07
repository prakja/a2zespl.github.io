ActiveAdmin.register Answer do
  remove_filter :versions, :user
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"
end
