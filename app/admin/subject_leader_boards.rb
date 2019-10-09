ActiveAdmin.register SubjectLeaderBoard do
  remove_filter :subject, :user
  preserve_default_filters!
  scope :paid_students
  filter :subjectId_eq, as: :number, label: "Subject ID"
  filter :userId_eq, as: :number, label: "User ID"

  controller do
    def scoped_collection
      super.includes(:subject, user: :user_profile)
    end
  end

  index do
    id_column
    column :rank
    column :user
    column :subject
    column :score
    column :correctAnswerCount
    column :incorrectAnswerCount
    column :accuracy
    actions
  end

end
