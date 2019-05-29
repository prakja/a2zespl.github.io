ActiveAdmin.register SubTopic do
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
  remove_filter :questions, :subTopicQuestions, :topic, :subTopicVideos, :videos
  permit_params :name, :topicId

  filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  preserve_default_filters!

  scope :botany
  scope :chemistry
  scope :physics
  scope :zoology

  form do |f|
    f.inputs "Sub Topic" do
      f.input :name
      f.input :topic, input_html: { class: "select2" }, :collection => Topic.neetprep_course.pluck(:name, :'Subject.name', :id).map{|topic_name, subject_name, topic_id| [topic_name + " - " + subject_name, topic_id]}
    end
    f.actions
  end

end
