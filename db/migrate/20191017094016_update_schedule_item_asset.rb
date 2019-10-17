class UpdateScheduleItemAsset < ActiveRecord::Migration[5.2]
  def change
    add_column "ScheduleItemAsset", "assetLink", :text
    add_column "ScheduleItemAsset", "assetName", :string
    remove_column "ScheduleItemAsset", :asset
  end
end
