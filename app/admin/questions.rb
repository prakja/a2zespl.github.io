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
  remove_filter :detail, :topics, :questionTopics, :subTopic, :questionSubTopics
  # make a drop down menu
  filter :detail_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :topics_id_eq, as: :select, collection: -> { Topic.distinct_name }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Topic"
  filter :id_eq, as: :number, label: "Question ID"
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course
  index do
    id_column
    column (:question) { |question| raw(question.question)  }
    column (:explanation) { |question| raw(question.explanation)  }
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
    end
    f.actions
  end
end
