class ChangeLiveClass < ActiveRecord::Migration[5.2]
  def change
    rename_table :LiveClasses, :LiveClass

    add_index :LiveClassUser,   [:liveClassId, :userId]
    add_index :CourseLiveClass, [:liveClassId, :courseId]
  end
end
