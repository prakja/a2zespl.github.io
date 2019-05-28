ActiveAdmin.register CustomerIssue do
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

remove_filter :topic, :question, :video

permit_params :resolved

filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
preserve_default_filters!

form do |f|
  f.inputs "Issues" do
    f.input :resolved
  end
  f.actions
end
end
