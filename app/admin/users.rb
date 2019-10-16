ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :blockedUser
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

remove_filter :schedule_item_users, :user_profile, :customer_supports, :doubts, :test_attempts, :user_profile_analytics, :user_action, :user_video_stats, :user_courses, :common_rank, :subject_rank

form do |f|
  f.inputs "User" do
    f.input :blockedUser
  end
  f.actions
end

action_item :user, only: :show do
  link_to 'User Doubt Stat', "/user_doubt_counts/stats?user=" + resource.id.to_s
end

action_item :user, only: :show do
  link_to 'User Activity', "/user_analytics/show?userId=" + resource.id.to_s
end

# controller do
#   def scoped_collection
#     super.left_outer_joins(:user_video_stats).select('"User".*, COUNT("UserVideoStat"."id") as video_count').group('"User"."id"')
#   end
# end

# filter :video_count_eq, label: "Watch count", as: :number
preserve_default_filters!
# scope :free_users
# scope :paid_users

index do
  id_column
  column :name
  column :email
  column :phone
  column :role
  actions
end

sidebar :user_activity, only: :show do
  ul do
    li link_to "Doubts", admin_doubts_path(q: { userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "Test Attempts", admin_test_attempts_path(q: { userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "User Profile Analytics", admin_user_profile_analytics_path(q: { userId_eq: user.id})
    li link_to "Courses", admin_user_courses_path(q: {userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "MCQ Answers", admin_answers_path(q: {userId_eq: user.id}, order: 'createdAt_desc')
    li link_to "Subject Ranks", admin_subject_leader_boards_path(q: {userId_eq: user.id}, order: 'rank_asc')
    li link_to "Topic Ranks", admin_topic_leader_boards_path(q: {userId_eq: user.id}, order: 'rank_asc')
    li link_to "Overall Rank", admin_common_leader_boards_path(q: {userId_eq: user.id}, order: 'rank_asc')
    li raw("Videos Watched " + "(" + user.user_video_stats.where(completed: true).count.to_s + ")")
  end
end

end
