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

remove_filter :schedule_item_users, :user_profile, :customer_supports, :doubts, :test_attempts, :user_profile_analytics

form do |f|
  f.inputs "User" do
    f.input :blockedUser
  end
  f.actions
end

sidebar :user_activity, only: :show do
  ul do
    li link_to "Doubts", admin_doubts_path(q: { userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "Test Attempts", admin_test_attempts_path(q: { userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "User Profile Analytics", admin_user_profile_analytics_path(q: { userId_eq: user.id})
  end
end

end
