ActiveAdmin.register CustomerSupport do
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

remove_filter :user, :admin_user
permit_params :resolved, :deleted

filter :issueType_eq, as: :select, collection: ["Pendrive_Not_Working", "Video_Not_Playing", "Test_Not_Working", "Website_Not_Working"], label: "Issue Type"
filter :resolved
preserve_default_filters!

action_item :show_more, only: :index do
  link_to 'More phones', "/admin/customer_supports?showMorePhone=1"
end

batch_action :assign_issues, form: -> do {
  assignTo: AdminUser.distinct_name
} end do |ids, inputs|
  assign_to = inputs['assignTo']
  p ids
  p assign_to
  admin_user_id = AdminUser.where(email: assign_to).first.id
  ids.each do |id|
    issue = CustomerSupport.find(id)
    if not issue.adminUserId.blank?
      next
    end
    issue.adminUserId = admin_user_id
    issue.save
  end
end

batch_action :unassign_issues do |ids|
  ids.each do |id|
    issue = CustomerSupport.find(id)
    if issue.adminUserId.blank?
      next
    end
    issue.adminUserId = nil
    issue.save
  end
end

# scope :my_issues, show_count: true

index do
  selectable_column
  id_column
  column :user
  if params[:showMorePhone]
    column "student phone 1" do |customerSupport|
      customerSupport.user.phone
     end
     column "student phone 2" do |customerSupport|
      if customerSupport.user.user_profile
        customerSupport.user.user_profile.phone
      end
     end
  end
  column :content
  column :phone
  column :email
  column :issueType
  column :userData
  column :deleted
  toggle_bool_column :resolved
  column :admin_user
  column :createdAt
  actions
end

form do |f|
  f.inputs "Issues" do
    f.input :resolved
    f.input :deleted
  end
  f.actions
end

end
