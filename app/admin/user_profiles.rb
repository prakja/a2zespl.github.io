ActiveAdmin.register UserProfile do

  remove_filter :user
  permit_params :displayName, :allowVideoDownload, :allowDeprecatedNcert, :picture
  controller do
    def scoped_collection
      super.includes(user: :user_profile)
    end
  end

  form do |f|
    f.inputs "UserProfile" do
      f.input :displayName
      f.input :allowVideoDownload
      f.input :allowDeprecatedNcert
      f.input :picture
    end
    f.actions
  end

end
