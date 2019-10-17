ActiveAdmin.register ScheduleItemAsset do
  remove_filter :scheduleItem
  permit_params :createdAt, :updatedAt, :asset, :scheduleItem, :ScheduleItem_id
end