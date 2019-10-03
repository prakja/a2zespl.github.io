ActiveAdmin.register TopicLeaderBoard do
  remove_filter :topic, :user
  preserve_default_filters!
  scope :paid_students
  filter :topicId_eq, as: :number, label: "Topic ID"
  filter :userId_eq, as: :number, label: "User ID"

  controller do
    def scoped_collection
      super.includes(:topic, user: :user_profile)
    end
  end
end
