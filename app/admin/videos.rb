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
  active_admin_import validate: true,
    timestamps: true,
    headers_rewrites: { 'name': :name, 'description': :description, 'thumbnail': :thumbnail, 'url': :url, 'language': :language, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
    before_batch_import: ->(importer) {
      # add created at and upated at
      p importer.options[:csv_options]
      time = Time.now
      importer.csv_lines.each do |line|
        topicId = line[-1]
        line.pop
        importer.options[:csv_options]['topicId'] = topicId
        importer.options[:csv_options]['time'] = time
        line.insert(-1, time)
        line.insert(-1, time)
      end
    },
    after_import:  ->(importer){
      p "after_import"
      time = importer.options[:csv_options]['time']
      topicId = importer.options[:csv_options]['topicId']
      videos = Video.where(createdAt: time)
      videos.each do |video|
        videoId = video[:id]
        Video.find(videoId).update(updatedAt: Time.now)
        if topicId.include? "|"
          topicIds = topicId.split("|")
          topicIds.each do |id|
            p id
            ChapterVideo.create(chapterId: id.to_i, videoId: videoId)
          end
        else
          ChapterVideo.create(chapterId: topicId.to_i, videoId: videoId)
        end
      end
    },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: name',	'description', 'thumbnail', 'url', 'language', 'topicId'.
        Remove the header from the CSV before uploading.",
        csv_headers: ['name',	'description', 'thumbnail', 'url', 'language', 'createdAt', 'updatedAt']
    )
  remove_filter :topics, :videoTopics, :videoSubTopics, :subTopics, :issues, :versions, :video_annotations, :notes, :user_video_stats
  filter :id_eq, as: :number, label: "Video ID"
  filter :topics_name, as: :string, label: "Chapter"
  filter :subTopics_name, as: :string, label: "Sub Topic"
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

  action_item :add_link, only: :show do
    link_to 'Add Video Link', '../../admin/video_links/new?video_link[videoId]=' + resource.id.to_s
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
      panel "Video Links" do
        table_for video.videoLinks do
          column :name
          column :url
          column :time
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

  action_item :add_chapter, only: :show do
    link_to 'Add Chapter', '/videos/add_chapter_video/' + resource.id.to_s, target: :_blank
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
