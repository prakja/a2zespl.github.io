class UpdateScheduleItemTable < ActiveRecord::Migration[5.2]
  def change
    change_column "ScheduleItem", "topicId", :integer, :null => true
  end
end
