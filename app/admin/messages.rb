ActiveAdmin.register Message do
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

  remove_filter :user, :group, :question
  permit_params :userId, :groupId, :content, :type, :deleted, :createdAt, :updatedAt, :questionId

  filter :userId
  filter :groupId
  filter :questionId
  preserve_default_filters!

  form do |f|
    f.inputs "Message" do
      f.input :userId
      f.input :groupId
      f.input :content
      f.input :type, as: :select, :collection => ["normal", "joinChat", "leftChat", "analytics", "pdf", "question"]
      f.input :questionId
    end
    f.actions
  end
end
