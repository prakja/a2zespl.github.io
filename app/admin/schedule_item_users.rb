ActiveAdmin.register ScheduleItemUser do
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

  remove_filter :scheduleItem, :user
  permit_params :createdAt, :updatedAt, :userId, :scheduleItem, :scheduleItemId, :completed

  form do |f|
    f.inputs "Schedule Item User" do
      f.input :userId
      f.input :scheduleItem
      f.input :completed
    end
    f.actions
  end

  index do
    id_column
    column :scheduleItem
    column (:user) {|schedule_item_user|
      raw('<a target="_blank" href="../admin/users/' + schedule_item_user.user.id.to_s + '">' + schedule_item_user.user.name + '</a>')      
    }
    column :completed
    actions
  end

end
