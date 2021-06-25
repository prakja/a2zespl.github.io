ActiveAdmin.register VideoSentence do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :videoId, :chapterId, :sectionId, :sentence, :timestampStart, :timestampEnd, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:videoId, :chapterId, :sectionId, :sentence, :timestampStart, :timestampEnd, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter :chapter, :section, :versions, :detail, :questions
  permit_params :sentence
  filter :videoId, as: :numeric
  preserve_default_filters!

  action_item only: :index do
    link_to 'Upload Transcription output', action: :upload_transcribe
  end

  collection_action :upload_transcribe do
    render 'admin/video_setences/import_transcribe'
  end

  collection_action :import_transcribe, method: :post do
    json, videoId =  params[:outputJson] || false, params[:videoId] || false

    if json and videoId
      msg = parse_transcribe_output videoId: videoId, json: json
      if msg.nil?
        flash[:danger] = "Kindly make sure the video Id is valid & file is in json format !"
      else
        flash[:notice] = msg
      end
    end
    redirect_to action: :index
  end

  index do
    selectable_column
    id_column
    column ("Video") { |vs|auto_link(vs.video)}
    column ("Chapter") {|vs| auto_link(vs.chapter) }
    column (:sentence) { |vs| best_in_place vs, :sentence, url: [:admin, vs] }
    column (:sentenceAlt) { |vs| best_in_place vs, :sentence1, url: [:admin, vs]}
    column ("Timestamp") { |vs| "#{vs.timestampStart} - #{vs.timestampEnd}"}
  end

  show do
    attributes_table do
      row :id
      row :video do |videoSentence|
        auto_link(videoSentence.video)
      end
      row :chapter do |videoSentence|
        auto_link(videoSentence.chapter)
      end
      row :sentence do |videoSentence|
        best_in_place videoSentence, :sentence, as: :input, url: [:admin, videoSentence]
      end
      row :sentenceAlt do |videoSentence|
        best_in_place videoSentence, :sentence1, as: :input, url: [:admin, videoSentence]
      end
      row ("Timestamp") do |videoSentence|
        raw("<a target='_blank' href='/admin/videos/#{videoSentence.videoId}/play?start_time=#{videoSentence.timestampStart}'> #{videoSentence.timestampStart} - #{videoSentence.timestampEnd}  </a>")
      end
      row :questions do |videoSentence|
        videoSentence.questions
      end
    end
  end

  controller do
    include VideoSentenceHelper

    def scoped_collection
      super.hinglish.addDetail
    end

    def find_by_sentence
      q = params["q"]
      chapterId = q["chapterId_eq"].to_i
      sentence = q["groupings"]["0"]["sentence_contains"].to_s

      query = 'to_tsvector(\'english\', sentence1) @@ to_tsquery(\'english\', ?) OR to_tsvector(\'english\', sentence) @@ to_tsquery(\'english\', ?)'
      nz_sent = sentence.gsub(' ', " & ")

      video_sentence = VideoSentence.where(query, nz_sent, nz_sent) # chapterId is also injected to the query
        .order(:videoId, :timestampStart)

      video_sentence = video_sentence.uniq { |s| [s.videoId, s.timestampStart]}
      render json: video_sentence.to_json(methods: [:transcribed_sentence]), status: 200
    end
  end
end
