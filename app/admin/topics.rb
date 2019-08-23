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
  remove_filter :questions, :topicQuestions, :subject, :videos, :topicVideos, :doubts, :issues, :scheduleItems, :subjects, :subTopics
  scope :neetprep_course
  sidebar :related_data, only: :show do
    ul do
      li link_to "Questions", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'id_asc')
      li link_to "Videos", admin_videos_path(q: { videoTopics_chapterId_eq: topic.id}, order: 'id_asc')
    end
  end
end
