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
  remove_filter :questions, :subTopicQuestions, :topic, :subTopicVideos, :videos, :versions
  permit_params :name, :topicId

  filter :topic_id_eq, as: :select, collection: -> { Topic.main_course_topic_name_with_subject}, label: "Chapter"
  preserve_default_filters!

  scope :botany, show_count: false
  scope :chemistry, show_count: false
  scope :physics, show_count: false
  scope :zoology, show_count: false
  scope :all, show_count: false

  index do
    id_column
    column :topic
    columns_to_exclude = ["id", "createdAt", "updatedAt", "deleted", "position", "topicId"]
    (SubTopic.column_names - columns_to_exclude).each do |c|
      column c.to_sym
    end
    if (current_admin_user.role == 'admin' or current_admin_user.role == 'faculty') and (params["scope"].present? or (params[:q].present? and (params[:q][:topic_id_eq].present? or params[:q][:topic_id_in].present?)))
      column :questions_count, sortable: true
    end
    actions
  end

  form do |f|
    f.inputs "Sub Topic" do
      f.input :name
      f.input :topic, input_html: { class: "select2" }, :collection => Topic.neetprep_course.pluck(:name, :'Subject.name', :id).map{|topic_name, subject_name, topic_id| [topic_name + " - " + subject_name, topic_id]}
    end
    f.actions
  end

  controller do
    def scoped_collection
      if params[:scope].present? or (params[:q].present? and (params[:q][:topic_id_eq].present? or params[:q][:topic_id_in].present?))
        super.left_outer_joins(:questions).select('"SubTopic".*, count(distinct("Question"."id")) as questions_count').group('"SubTopic"."id"')
      else
        super
      end
    end
  end

end
