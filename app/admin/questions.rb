ActiveAdmin.register Question do
  config.sort_order = 'sequenceId_asc_and_id_asc'
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
  remove_filter :details, :topics, :questionTopics, :subTopics, :questionSubTopics, :question_analytic, :issues, :versions, :doubts, :questionTests, :tests
  permit_params :question, :correctOptionIndex, :explanation, :type, :deleted, :testId, :proofRead, topic_ids: [], subTopic_ids: [], test_ids: [], details_attributes: [:id, :exam, :year, :_destroy]

  # before_filter only: :index do
  #   if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
  #     params['q'] = {:explanation_cont => '<video'}
  #   end
  # end

  # make a drop down menu
  filter :topics_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :details_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :details_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"
  filter :id_eq, as: :number, label: "Question ID"
  filter :subject_name, as: :select, collection: -> {Subject.subject_names}, label: "Subject"
  filter :tests
  filter :type, filters: ['eq'], as: :select, collection: -> { Question.distinct_type.map{|q_type| q_type["type"]} }, label: "Question Type"
  filter :explanation_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Has", multiple: true
  filter :explanation_not_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Does Not Have", multiple: true
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course

  controller do
    def scoped_collection
      super.left_outer_joins(:doubts).select('"Question".*, COUNT("Doubt"."id") as doubts_count').group('"Question"."id"')
    end
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

    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty' and params[:showProofRead] == 'yes'
     toggle_bool_column :proofRead
    end

    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty'
      column :doubts_count, sortable: true
      column ("Add explanation") { |question|
        raw('<a target="_blank" href="/questions/add_explanation/' + question.id.to_s + '">' + "Add Explanation" + '</a>')
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
        question.tests
      end
      row :type
      row :sequenceId
    end
  end

  csv do
    column :question
    column :explanation
    column :correctOptionIndex
  end

  # Label works with filters but not with scope xD
  scope :NEET_AIPMT_PMT_Questions, label: "NEET AIPMT PMT Questions"
  scope :AIIMS_Questions
  scope :empty_explanation
  # not working well so commenting out, checked with chapter filter
  #scope :include_deleted, label: "Include Deleted"

  action_item :similar_question, only: :show do
    link_to 'Find Similar Questions', '../../admin/questions?q[question_eq]=' + resource.question
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

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Question" do
      render partial: 'tinymce'
      f.input :question
      f.input :correctOptionIndex, as: :select, :collection => [["(1)", 0], ["(2)", 1], ["(3)", 2], ["(4)", 3]], label: "Correct Option"
      f.input :explanation
      f.input :tests, input_html: { class: "select2" }
      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      f.input :subTopics, input_html: { class: "select2" }, as: :select, :collection => SubTopic.topic_sub_topics(question.topics.length > 0 ? question.topics.map(&:id) : [])
      f.input :type, as: :select, :collection => ["MCQ-SO", "MCQ-AR", "MCQ-MO", "SUBJECTIVE"]
      f.input :sequenceId
    end
    f.has_many :details, new_record: true, allow_destroy: true do |detail|
      detail.inputs "Details" do
        detail.input :exam
        detail.input :year
      end
    end
    f.actions
  end
end
