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
  permit_params :question, :correctOptionIndex, :explanation, :deleted, :testId, topic_ids: [], subTopic_ids: []
  # make a drop down menu
  filter :detail_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :topics_id_eq, as: :select, collection: -> { Topic.distinct_name }, label: "Chapter"
  filter :subTopics_id_eq, as: :select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
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

      f.input :topics, as: :select, :collection => Topic.neetprep_course
      f.input :subTopics, as: :select, :collection => SubTopic.topic_sub_topics(question.topics.length > 0 ? question.topics.map(&:id) : [])
    end
    f.actions
  end
end
