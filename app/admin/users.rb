ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :blockedUser
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

remove_filter :schedule_item_users, :user_profile, :customer_supports

form do |f|
  f.inputs "User" do
    f.input :blockedUser
  end
  f.actions
end

end
