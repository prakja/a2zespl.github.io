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

  remove_filter :video, :chapter, :section
  preserve_default_filters!

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
        raw("<a target='_blank' href='#{videoSentence.playableUrlWithTimestamp}'> #{videoSentence.sentence} </a>")
      end
      row ("Timestamp start") do |videoSentence|
        videoSentence.timestampStart
      end
      row ("Timestamp end") do |videoSentence|
        videoSentence.timestampEnd
      end
    end
  end

  controller do
    def find_by_sentence
      sentence = params.require(:sentence)
      query = 'to_tsvector(\'english\', "sentence") @@ to_tsquery(\'english\', ?)'
      video_sentence = VideoSentence.where(query, sentence.gsub(' ', " & ")).order(:videoId, :timestampStart) # chapterId is also injected to the query
      video_sentence = video_sentence.uniq { |s| [s.videoId, s.timestampStart]}
      render json: video_sentence.to_json, status: 200
    end
  end
end
