class CreateScheduleItemAssets < ActiveRecord::Migration[5.2]
  def change
    create_table "ScheduleItemAsset" do |t|
      # t.references "ScheduleItem", "scheduleItemId", index: true, foreign_key: true
      t.belongs_to "ScheduleItem"
      t.text :asset
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
  end
end
