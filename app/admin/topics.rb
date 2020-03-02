ActiveAdmin.register Topic do
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
  remove_filter :questions, :topicQuestions, :subject, :videos, :topicVideos, :doubts, :issues, :scheduleItems, :subTopics, :versions, :topicSubjects, :topicChapterTests, :tests, :sections
  permit_params :free, :name, :image, :description, :position, :createdAt, :updatedAt, :seqid, :importUrl, :published, :isComingSoon, :subjectId, :subject_id, :sectionReady
  preserve_default_filters!
  filter :subjects, as: :searchable_select, multiple: true, collection: -> {Subject.neetprep_course_subjects}, label: "Subject"
  scope :neetprep_course
  sidebar :related_data, only: :show do
    ul do
      li link_to "Questions", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'id_asc')
      li link_to "Videos", admin_videos_path(q: { videoTopics_chapterId_eq: topic.id}, order: 'id_asc')
    end
  end

  index do
    id_column
    column :name
    column :description do |topic|
      truncate topic.description
    end
    column :seqId
    column ("Videos") { |topic|
      link_to "Videos", admin_videos_path(q: { videoTopics_chapterId_eq: topic.id}, order: 'id_asc')
    }
    column ("Questions") { |topic|
      link_to "Questions", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'id_asc')
    }
    toggle_bool_column :sectionReady
    actions
  end

  controller do
    def scoped_collection
      super.includes(:subject)
    end
  end
end
