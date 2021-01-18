ActiveAdmin.register Question do
  # config.sort_order = 'sequenceId_asc_and_id_asc'
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
  remove_filter :details, :questionTopics, :subTopics, :questionSubTopics, :question_analytic, :issues, :versions, :doubts, :questionTests, :tests, :bookmarks, :explanations, :hints, :answers, :translations, :notes, :systemTests, :topic, :subject, :lock_version
  permit_params :question, :correctOptionIndex, :explanation, :type, :level, :deleted, :testId, :topic, :topicId, :proofRead, :ncert, :lock_version, :paidAccess, topic_ids: [], subTopic_ids: [], systemTest_ids: [], details_attributes: [:id, :exam, :year, :_destroy]

  before_action :create_token, only: [:show]

  # before_filter only: :index do
  #   if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
  #     params['q'] = {:explanation_cont => '<video'}
  #   end
  # end

  # make a drop down menu
  filter :topics, as: :searchable_select, multiple: true, label: "Chapter", :collection => Topic.name_with_subject
  filter :subTopics_id_eq, as: :searchable_select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :details_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :details_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"
  filter :id_eq, as: :number, label: "Question ID"
  filter :subject_id_eq, as: :select, collection: -> {Subject.full_course_subject_names}, label: "Subject"
  filter :similar_questions, as: :number, label: "Similar to ID"
  filter :type, filters: ['eq'], as: :select, collection: -> { Question.distinct_type.map{|q_type| q_type["type"]} }, label: "Question Type"
  filter :level, filters: ['eq'], as: :select, collection: -> { Question.distinct_level.map{|q_type| q_type["level"]} }, label: "Question Level"
  filter :explanation_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Has", multiple: true
  filter :explanation_not_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Does Not Have", multiple: true
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course, show_count: false
  scope :image_question, show_count: false
  scope :test_image_question, show_count: false
  scope :unused_in_high_yield_bio, show_count: false
  scope :NEET_Test_Questions, show_count: false
  scope :not_neetprep_course, show_count: false

  controller do
    def scoped_collection
      if params["q"] and (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
        super.left_outer_joins(:doubts, :bookmarks).select('"Question".*, COUNT(distinct("Doubt"."id")) as doubts_count, COUNT(distinct("BookmarkQuestion"."id")) as bookmarks_count').group('"Question"."id"')
      else
        super 
      end
    end

    def create_token
      payload = {
        "type": "Question",
        "id": params[:id]
      }
      @token_lambda = JsonWebToken.encode_for_lambda(payload)
    end
  end

  member_action :history do
    @question = Question.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Question', item_id: @question.id)
    render "layouts/history"
  end

  # https://www.neetprep.com/api/v1/questions/id/edit
  index do

    # if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
    #   @index = 15 * (((params[:page] || 1).to_i) - 1)
    #       column :number do
    #           @index +=1
    #       end
    # end

    id_column
    column (:question) { |question| raw(question.question)  }
    column (:correctOption) { |question| question.options[question.correctOptionIndex] if not question.correctOptionIndex.blank? and not question.options.blank?}
    column (:explanation) { |question| raw(question.explanation)  }
    # column ("Link") {|question| raw('<a target="_blank" href="https://www.neetprep.com/api/v1/questions/' + (question.id).to_s + '/edit">Edit on NEETprep</a>')}
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'

    if (current_admin_user.role == 'admin' or current_admin_user.role == 'faculty' or current_admin_user.role == 'superfaculty') and params[:showProofRead] == 'yes'
      toggle_bool_column :proofRead
    end

    if (current_admin_user.role == 'admin' or current_admin_user.role == 'faculty' or current_admin_user.role == 'superfaculty') and params[:showNCERT] == 'yes'
      toggle_bool_column :ncert
    end

    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty'
      # p params["q"]["questionTopics_chapterId_in"]
      if params["q"] && (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
        column ("Doubts Count"), sortable: true do |question|
          link_to question.doubts_count, admin_doubts_path(q: {questionId_eq: question.id})
        end
        column :bookmarks_count, sortable: true
      end
      column ("Add explanation") { |question|
        raw('<a target="_blank" href="/questions/add_explanation/' + question.id.to_s + '">' + "Add Explanation" + '</a>')
      }
      column ("Add Hint") { |question|
        raw('<a target="_blank" href="/questions/add_hint/' + question.id.to_s + '">' + "Add Hint" + '</a>')
      }
    end
    actions
  end

  show do
    render partial: 'mathjax'
    attributes_table do
      row :id
      row :question do |question|
        raw(question.question)
      end
      row :explanation do |question|
        raw(question.explanation)
      end
      if question.explanations and question.explanations.length > 0
        row :explanations do |question|
          raw(question.explanations.pluck(:explanation).join(""))
        end
      end
      if question.translations and question.translations.length > 0
        row :translations do |question|
          raw('<a href="/admin/question_translations?q[questionId_eq]=' + question.id.to_s + '">View in Hindi</a>')
        end
      end
      row :options do |question|
        raw(question.options)
      end
      # row :correctOptionIndex
      row :correctOption do |question|
        question.options[question.correctOptionIndex] if not question.correctOptionIndex.blank?
      end
      row :topics do |question|
        question.topics
      end
      row :subTopics do |question|
        question.subTopics
      end
      row :tests do |question|
        question.systemTests
      end
      row :type
      row :level
      row :sequenceId
      row :orignalQuestionId do |question|
        question.orignalQuestionId.nil? ? nil : raw('<a target="_blank" href="/admin/questions/' + question.orignalQuestionId.to_s + '">' + "Original Question" + '</a>')
      end
    end
    active_admin_comments
  end

  csv do
    column (:id)
    column (:chapter_id) {|question| question&.topicId}
    column (:chapter) {|question| question&.topic&.name}
    column (:subject) {|question| question&.subject&.name}
    # column (:chapter) {|question| question&.topics&.first&.id}
    column (:subtopic_id) {|question| question&.subTopics&.first&.id}
    column (:subtopic) {|question| question&.subTopics&.first&.name}
    # column (:subject) {|question| question&.topics&.first&.subject&.name}
    column (:question) {|question| question.question && question.question.squish}
    column (:explanation) {|question| question.explanation && question.explanation.squish}
    column :options
    column :correctOptionIndex
  end

  # Label works with filters but not with scope xD
  scope :NEET_AIPMT_PMT_Questions, label: "NEET AIPMT PMT Questions", show_count: false
  scope :AIIMS_Questions, show_count: false
  scope :empty_explanation, show_count: false
  scope :missing_subTopics, show_count: false
  scope :missing_audio_explanation, show_count: false
  scope :missing_ncert_reference, show_count: false
  scope :test_questions, show_count: false
  # not working well so commenting out, checked with chapter filter
  #scope :include_deleted, label: "Include Deleted"

  action_item :similar_question, only: :show do
    link_to 'Find Similar Questions', '../../admin/questions?q[similar_questions]=' + resource.id.to_s
  end

  action_item :set_image_link, only: :show do
    link_to 'Set Image Link', '#'
  end

  action_item :see_physics_difficult_questions, only: :index do
    link_to 'Physics Difficult Questions', '../../questions/pdf_questions?subject=physics'
  end

  action_item :see_chemistry_difficult_questions, only: :index do
    link_to 'Chemistry Difficult Questions', '../../questions/pdf_questions?subject=chemistry'
  end

  action_item :see_botany_difficult_questions, only: :index do
    link_to 'Botany Difficult Questions', '../../questions/pdf_questions?subject=botany'
  end

  action_item :see_zoology_difficult_questions, only: :index do
    link_to 'Zoology Difficult Questions', '../../questions/pdf_questions?subject=zoology'
  end

  action_item :see_physics_easy_questions, only: :index do
    link_to 'Physics easy Questions', '../../questions/easy_questions?subject=physics'
  end

  action_item :see_chemistry_easy_questions, only: :index do
    link_to 'Chemistry easy Questions', '../../questions/easy_questions?subject=chemistry'
  end

  action_item :see_botany_easy_questions, only: :index do
    link_to 'Botany easy Questions', '../../questions/easy_questions?subject=botany'
  end

  action_item :see_zoology_easy_questions, only: :index do
    link_to 'Zoology easy Questions', '../../questions/easy_questions?subject=zoology'
  end

  action_item :see_ncert_marking, only: :index do
    link_to 'From NCERT Marking', request.params.merge(showNCERT: 'yes')
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Question" do
      render partial: 'tinymce'
      f.input :question
      f.input :correctOptionIndex, as: :select, :collection => [["(1)", 0], ["(2)", 1], ["(3)", 2], ["(4)", 3]], label: "Correct Option"
      f.input :explanation
      f.input :systemTests, include_hidden: false, input_html: { class: "select2" }, :collection => Test.where(userId: nil).order(createdAt: :desc).limit(100)
      render partial: 'hidden_test_ids', locals: {tests: f.object.systemTests}
      f.input :topic, include_hidden: false, input_html: { class: "select2" }, :collection => Topic.main_course_topic_name_with_subject if current_admin_user.role != 'support'
      render partial: 'hidden_topic_ids', locals: {topics: f.object.topics} if current_admin_user.role != 'support'
      f.input :subTopics, input_html: { class: "select2" }, as: :select, :collection => SubTopic.topic_sub_topics(question.topicId != nil ? question.topicId : (question.topics.length > 0 ? question.topics.map(&:id) : [])) if current_admin_user.role != 'support'
      f.input :type, as: :select, :collection => ["MCQ-SO", "MCQ-AR", "MCQ-MO", "SUBJECTIVE"]
      f.input :level, as: :select, :collection => ["BASIC-NCERT", "MASTER-NCERT"]
      f.input :paidAccess
      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject if current_admin_user.role != 'support'
      f.input :lock_version, :as => :hidden
    end
    f.has_many :details, new_record: true, allow_destroy: true do |detail|
      detail.inputs "Details" do
        detail.input :exam, as: :select, :collection => ["AIIMS", "AIPMT", "BOARD", "NEET", "PMT"]
        detail.input :year
      end
    end
    f.actions
  end
end
