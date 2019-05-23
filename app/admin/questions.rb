ActiveAdmin.register Question do
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
  remove_filter :detail, :topics, :questionTopics, :subTopics, :questionSubTopics, :question_analytic, :test
  permit_params :question, :correctOptionIndex, :explanation, :deleted, :testId, topic_ids: [], subTopic_ids: []
  # make a drop down menu
  filter :topics_id_eq, as: :select, collection: -> { Topic.distinct_name }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :detail_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :detail_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"    
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"  
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"    
  filter :id_eq, as: :number, label: "Question ID"
  filter :type, filters: ['eq'], as: :select, collection: -> { Question.distinct_type.map{|q_type| q_type["type"]} }, label: "Question Type"
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course

  # prevents N+1 queries to your database, don't know if that's good or bad. xD 
  # controller do
  #   def scoped_collection
  #     super.includes :question_analytic
  #   end
  # end

  index do
    id_column
    column (:question) { |question| raw(question.question)  }
    column (:explanation) { |question| raw(question.explanation)  }
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'
    actions
  end

  show do
    attributes_table do
      row :question do |question|
        raw(question.question)
      end
      row :explanation do |question|
        raw(question.explanation)
      end
      row :options do |question|
        raw(question.options)
      end
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

  # Label works with filters but not with scope xD
  scope :NEET_AIPMT_PMT_Questions, label: "NEET AIPMT PMT Questions"
  scope :AIIMS_Questions
  scope :include_deleted, label: "Include Deleted"

  form do |f|
    f.inputs "Question" do
      f.input :question, as: :quill_editor
      f.input :correctOptionIndex
      f.input :explanation, as: :quill_editor
      f.input :testId
      f.input :deleted

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.neetprep_course.pluck(:name, :'Subject.name', :id).map{|topic_name, subject_name, topic_id| [topic_name + " - " + subject_name, topic_id]}
      f.input :subTopics, input_html: { class: "select2" }, as: :select, :collection => SubTopic.topic_sub_topics(question.topics.length > 0 ? question.topics.map(&:id) : [])
    end
    f.actions
  end
end
