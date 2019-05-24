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
  filter :topics_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  preserve_default_filters!

  permit_params :name, :description, :url, :thumbnail, :duration, :seqId, :youtubeUrl, topic_ids: [], subTopic_ids: []
  scope :neetprep_course

  index do
    id_column
    column :name
    column :duration
    column ("Link") {|video| raw('<a href="https://www.neetprep.com/video-class/' + (video.id).to_s + '-admin">View on NEETprep</a>')}
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :url
      row :duration
      row :seqId
      row :youtubeUrl
      row :topics do |video|
        video.topics
      end
      row :subTopics do |video|
        video.subTopics
      end
    end
  end

  form do |f|
    f.inputs "Video" do
      f.input :name
      f.input :description
      f.input :url
      f.input :duration, as: :number, label: "Duration in seconds"
      f.input :seqId, as: :number
      f.input :youtubeUrl

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      f.input :subTopics, input_html: { class: "select2" }, :collection => SubTopic.topic_sub_topics(f.object.topics.length > 0 ? f.object.topics.map(&:id) : [])
    end
    f.actions
  end
end
