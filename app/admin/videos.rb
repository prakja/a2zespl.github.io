ActiveAdmin.register Video do
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
  remove_filter :topics, :videoTopics, :videoSubTopics, :subTopics
  filter :topics_id_eq, as: :select, collection: -> { Topic.distinct_name }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  preserve_default_filters!
end
