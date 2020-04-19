ActiveAdmin.register BookmarkQuestion do
  remove_filter :question, :user
  controller do
    def scoped_collection
      super.includes(:question, user: :user_profile)
    end
  end
end
