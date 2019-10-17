ActiveAdmin.register ScheduleItemAsset do
  remove_filter :scheduleItem
  permit_params :createdAt, :updatedAt, :assetName, :assetLink, :scheduleItem, :ScheduleItem_id

  form do |f|
    f.inputs "Schedule Item Asset" do
      f.input :assetName, as: :string
      f.input :assetLink, as: :string
      f.input :scheduleItem, input_html: { class: "select2" }, :collection => ScheduleItem.topper_schedule_items
      # f.input :createdAt, label: "Created At", as: :datetime_picker
      # f.input :updatedAt, label: "Updated At", as: :datetime_picker
    end
    f.actions
  end
end