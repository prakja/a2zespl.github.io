class AddShortDescToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column "Course", :shortDescription, :string
  end
end
