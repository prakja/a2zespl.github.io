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
  permit_params :sentence, :timestampStart, :timestampEnd, :videoId, :chapterId
  filter :videoId, as: :numeric
  filter :similar_to_question, as: :number, label: "Similar to Question ID"
  preserve_default_filters!

  action_item only: :index do
    link_to 'Upload Transcription output', action: :upload_transcribe
  end

  collection_action :upload_transcribe do
    render 'import_transcribe'
  end


  member_action :add_comment, method: [:put] do
    sentenceId, comment = params[:id].to_i, params[:question_video_sentence][:comment_without_null]
    QuestionVideoSentence.where(:id => sentenceId).update(:comment => comment)
    head :ok
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
    if params[:q].present? and params[:q][:similar_to_question].present? and not params[:q][:similar_to_question].empty?
      column :prevSentence 
    else
      column ("Chapter") { |vs| auto_link(vs.chapter) }
    end
    column (:sentence) { |vs| best_in_place vs, :sentence, url: [:admin, vs] }
    if params[:q].present? and params[:q][:similar_to_question].present? and not params[:q][:similar_to_question].empty?
      column :nextSentence
    else
      column (:sentenceAlt) { |vs| best_in_place vs, :sentence1, url: [:admin, vs]}
    end
    column ("Timestamp") { |vs| "#{vs.timestampStart} - #{vs.timestampEnd}"}

    if params[:q].present? and params[:q][:similar_to_question].present? and not params[:q][:similar_to_question].empty?
      scope = params[:q][:similar_to_question]
      questionId, exclude = scope[:questionId], scope[:exclude]

      question = Question.find(questionId)

      render partial: 'similar_to_question', :locals => {:question => question}
      render partial: 'keywords', :locals => {:question => question, :exclude_keywords => exclude}
    end

    actions defaults: false do |sentence|
      if params[:q].present? and params[:q][:similar_to_question].present?
        item "Add to Question", '#!', class: 'member_link', onclick: "add_sentence_mapping(#{sentence.id})"
      end
    end
  end

  member_action :mydup do
    video_sentence = VideoSentence.find(params[:id])
    @video_sentence = video_sentence.dup
    render 'active_admin/resource/new.html.arb', layout: false
  end

  action_item "Clone Video Sentence", :only => :show do
    link_to("Clone", mydup_admin_video_sentence_path(id: resource.id))
  end

  form do |f|
    f.inputs "Video Sentence" do
      f.input :videoId
      f.input :chapterId
      f.input :sentence
      f.input :timestampStart
      f.input :timestampEnd
    end
    f.actions
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
      regex_data = (params[:q].present? and params[:q]["groupings"].present? and params[:q]["groupings"]["0"].present? and params[:q]["groupings"]["0"]["sentence_matches_regexp"].present?) ? params[:q]["groupings"]["0"]["sentence_matches_regexp"] : nil
      if regex_data
        super.hinglish.addDetail(regex_data)
      else
        if params[:q].present? and params[:q]["similar_to_question"].present?
          puts params[:q]["similar_to_question"]
          questionId = params[:q]["similar_to_question"]
          questionId = questionId['questionId'] || questionId

          exclude = params[:q]["exclude"] || ''
          exclude_keyword = exclude.split(',')
          params[:q]["similar_to_question"] = {:questionId => questionId.to_i, :exclude => exclude_keyword}
        else
          super
        end
        super.hinglish.addDetail
      end
    end

    def add_sentence_to_question
      begin
        questionId = params.require('questionId').to_i
        sentenceId = params.require('sentenceId').to_i

        QuestionVideoSentence.create(:videoSentenceId => sentenceId, :questionId => questionId)
        render json: {:msg => :ok}, status: 200
      rescue => exception
        render json: {:error => exception.to_s}, status: 500
      end
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
