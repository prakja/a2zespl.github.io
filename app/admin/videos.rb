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
  remove_filter :topics, :videoTopics, :videoSubTopics, :subTopics, :issues, :versions, :video_annotations, :notes, :user_video_stats
  filter :id_eq, as: :number, label: "Video ID"
  filter :topics_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  # filter :subTopics_id_not_cont_any, label: "Has Sub-topics", as: :boolean
  preserve_default_filters!

  permit_params :name, :description, :url, :thumbnail, :language, :duration, :seqId, :youtubeUrl, topic_ids: [], subTopic_ids: []
  scope :neetprep_course
  scope :maths_course

  scope :botany
  scope :chemistry
  scope :physics
  scope :zoology

  action_item :add_annotation, only: :show do
    # video_annotation[videoId]=450&video_annotation[annotationType]=Note
    link_to 'Add Annotation', '../../admin/video_annotations/new?video_annotation[annotationType]=Note&video_annotation[videoId]=' + resource.id.to_s
  end

  index do
    id_column
    column :name
    column :duration
    column :language
    column ("Link") {|video| raw('<a target="_blank" href="https://www.neetprep.com/video-class/' + (video.id).to_s + '-admin">View on NEETprep</a>')}
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'
    column ("History") {|video| raw('<a target="_blank" href="/admin/videos/' + (video.id).to_s + '/history">View History</a>')}
    actions
  end

  show do |video|
    attributes_table do
      row :name
      row :description
      row :url
      row :duration
      row :language
      row :seqId
      row :youtubeUrl
      row :topics do |video|
        video.topics
      end
      row :subTopics do |video|
        video.subTopics
      end
      panel "Video Annotation" do
        table_for video.notes do
          column :content do |note|
            raw(note.content)
          end
          column :time do |note|
            ms = note.video_annotation.videoTimeMS
            hours = ms / (1000 * 60 * 60)
            ms = ms - hours * (60*60*1000)
            minutes = ms / (1000 * 60) % 60
            ms = ms - minutes * (60*1000)
            seconds = ms / 1000
            raw(hours.to_s.rjust(2, '0') + ":" + minutes.to_s.rjust(2, '0') + ":" + seconds.to_s.rjust(2, '0'))
          end
        end
      end
    end
  end

  csv do
    column (:subject) {|video| raw(video.topics[0].subject.name)}
    column (:chapter) {|video| raw(video.topics[0].name)}
    column :name
  end

  member_action :history do
    @video = Video.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Video', item_id: @video.id)
    render "layouts/history"
  end

  form do |f|
    f.inputs "Video" do
      f.input :name
      f.input :description
      f.input :url, as: :string
      f.input :duration, as: :number, label: "Duration in seconds"
      f.input :seqId, as: :number
      f.input :youtubeUrl
      f.input :thumbnail, as: :string
      f.input :language, as: :select, :collection => ["hinglish", "english"]

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      f.input :subTopics, input_html: { class: "select2" }, :collection => SubTopic.topic_sub_topics(f.object.topics.length > 0 ? f.object.topics.map(&:id) : [])
    end
    f.actions
  end
end
