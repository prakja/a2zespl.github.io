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
  remove_filter :detail, :topics, :questionTopics, :subTopics, :questionSubTopics, :question_analytic
  permit_params :question, :correctOptionIndex, :explanation, :deleted, :testId, topic_ids: [], subTopic_ids: []
  # make a drop down menu
  filter :topics_id_eq, as: :select, collection: -> { Topic.distinct_name }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :detail_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :detail_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"    
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"  
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"    
  filter :id_eq, as: :number, label: "Question ID"
  filter :type, as: :string, label: "Question Type"
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

      f.input :topics, as: :select, :collection => Topic.neetprep_course
      f.input :subTopics, as: :select, :collection => SubTopic.distinct_name
    end
    f.actions
  end
end
