ActiveAdmin.register Question do
  config.sort_order = 'createdAt_desc'
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
  remove_filter :detail, :topics, :questionTopics, :subTopics, :questionSubTopics, :question_analytic, :test, :issues, :versions
  permit_params :question, :correctOptionIndex, :explanation, :jee, :deleted, :testId, topic_ids: [], subTopic_ids: []

  # before_filter only: :index do
  #   if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
  #     params['q'] = {:explanation_cont => '<video'}
  #   end
  # end

  # make a drop down menu
  filter :topics_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :detail_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :detail_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"
  filter :id_eq, as: :number, label: "Question ID"
  filter :testId_eq, as: :number, label: "Test ID"
  filter :type, filters: ['eq'], as: :select, collection: -> { Question.distinct_type.map{|q_type| q_type["type"]} }, label: "Question Type"
  filter :explanation_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Has", multiple: true
  filter :explanation_not_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Does Not Have", multiple: true
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course

  # prevents N+1 queries to your database, don't know if that's good or bad. xD
  # controller do
  #   def scoped_collection
  #     super.includes :question_analytic
  #   end
  # end

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
    column (:explanation) { |question| raw(question.explanation)  }
    # column ("Link") {|question| raw('<a target="_blank" href="https://www.neetprep.com/api/v1/questions/' + (question.id).to_s + '/edit">Edit on NEETprep</a>')}
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'
    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty'
      toggle_bool_column :jee
    else
      column :jee
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
        question.options[question.correctOptionIndex]
      end
      row :topics do |question|
        question.topics
      end
      row :subTopics do |question|
        question.subTopics
      end
      row :test do |question|
        question.test
      end
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
  # not working well so commenting out, checked with chapter filter
  #scope :include_deleted, label: "Include Deleted"

  action_item :similar_question, only: :show do
    link_to 'Find Similar Questions', '../../admin/questions?q[question_eq]=' + resource.question
  end

  form do |f|
    f.inputs "Question" do
      render partial: 'tinymce'
      f.input :question
      f.input :correctOptionIndex, as: :select, :collection => [["(1)", 0], ["(2)", 1], ["(3)", 2], ["(4)", 3]], label: "Correct Option"
      f.input :explanation
      f.input :test, input_html: { class: "select2" }

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      f.input :subTopics, input_html: { class: "select2" }, as: :select, :collection => SubTopic.topic_sub_topics(question.topics.length > 0 ? question.topics.map(&:id) : [])
    end
    f.actions
  end
end
