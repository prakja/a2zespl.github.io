class AddColumnInCourse < ActiveRecord::Migration[5.2]
  def change
    add_column "Course", "typeId", :integer, default: nil
  end
end
