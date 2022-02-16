class AddHasLiveClassToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :Course, :hasLiveClass, :boolean, default: false
  end
end
