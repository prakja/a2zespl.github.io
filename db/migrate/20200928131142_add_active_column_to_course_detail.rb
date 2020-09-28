class AddActiveColumnToCourseDetail < ActiveRecord::Migration[5.2]
  def change
    add_column "CourseDetail", "live", :boolean, :default => false
  end
end
