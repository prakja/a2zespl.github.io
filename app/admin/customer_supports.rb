ActiveAdmin.register CustomerSupport do
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
permit_params :resolved, :deleted

filter :issueType_eq, as: :select, collection: ["Pendrive_Not_Working", "Video_Not_Playing", "Test_Not_Working", "Website_Not_Working"], label: "Issue Type"
filter :resolved
preserve_default_filters!

index do
  id_column
  column :user
  column "student phone 1" do |customerSupport|
   customerSupport.user.phone
  end
  column "student phone 2" do |customerSupport|
   if customerSupport.user.user_profile
     customerSupport.user.user_profile.phone
   end
  end
  column :content
  column :phone
  column :issueType
  column :deleted
  toggle_bool_column :resolved
  column :createdAt
  actions
end

form do |f|
  f.inputs "Issues" do
    f.input :resolved
    f.input :deleted
  end
  f.actions
end

end
