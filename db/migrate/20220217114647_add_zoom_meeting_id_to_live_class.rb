class AddZoomMeetingIdToLiveClass < ActiveRecord::Migration[5.2]
  def change
    add_column :LiveClass, :zoomMeetingId, :string, null: true, default: nil
    add_column :LiveClass, :zoomEmail,     :string, null: true, default: nil
  end
end
