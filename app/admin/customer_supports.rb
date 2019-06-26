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
preserve_default_filters!

form do |f|
  f.inputs "Issues" do
    f.input :resolved
    f.input :deleted
  end
  f.actions
end

end
