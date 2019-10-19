ActiveAdmin.register CommonLeaderBoard do
  config.sort_order = 'rank_asc'
  remove_filter :user
  preserve_default_filters!
  scope :paid_students
  filter :userId_eq, as: :number, label: "User ID"

  controller do
    def scoped_collection
      super.includes(user: :user_profile)
    end
  end
end
