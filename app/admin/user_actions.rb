ActiveAdmin.register UserAction do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
remove_filter :user

index do
  id_column
  column :user
  column :count
  actions
end

filter :user_id_eq, as: :number, label: "User ID"
preserve_default_filters!

end
