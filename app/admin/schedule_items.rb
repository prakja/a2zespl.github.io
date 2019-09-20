ActiveAdmin.register ScheduleItem do
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

remove_filter :scheduleItemUsers, :topic
permit_params :name, :schedule, :scheduleId, :topic, :topicId, :hours, :link, :scheduledAt, :createdAt, :updatedAt, :description

form do |f|
  f.inputs "Schedule Item" do
    f.input :name, as: :string
    f.input :description, as: :quill_editor
    f.input :schedule
    f.input :topic, input_html: { class: "select2" }, :collection => Topic.name_with_subject
    f.input :hours
    f.input :link, as: :string
    f.input :scheduledAt, label: "Scheduled At", as: :datetime_picker
  end
  f.actions
end

index do
  id_column
  column :scheduledAt
  column :topic
  column :name
  column :hours
  column (:link) { |schedule_item| 
    raw('<a target="_blank" href="' + schedule_item.link + '">' + schedule_item.link + '</a>') if not schedule_item.link.blank?
  }
  column :schedule
  column (:description) { |schedule_item| raw(schedule_item.description)  }
  actions
end

end
