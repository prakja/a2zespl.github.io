ActiveAdmin.register UserProfileAnalytic do
remove_filter :user
preserve_default_filters!

scope :video_course_students

filter :test_count_present, as: :select, collection: ["yes", "no"]

controller do
  def scoped_collection
    super.includes(user: :user_profile)
  end
end

index do
  id_column
  column :user
  column :ansCount
  column :testCount
  column :videoCount
  column :ans7DaysCount
  column :test7DaysCount
  column :video7DaysCount
  column ("phone") { |user_profile_analytic|
    if not user_profile_analytic.user.phone.nil?
      user_profile_analytic.user.phone
    else
      if not user_profile_analytic.user.user_profile.nil?
        user_profile_analytic.user.user_profile.phone
      else
        raw '-'
      end
    end
  }
  column ("email") { |user_profile_analytic|
    if not user_profile_analytic.user.email.nil?
      user_profile_analytic.user.email
    else
      if not user_profile_analytic.user.user_profile.nil?
        user_profile_analytic.user.user_profile.email
      else
        raw '-'
      end
    end
  }
  actions
end

end
