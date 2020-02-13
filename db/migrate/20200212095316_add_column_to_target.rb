class AddColumnToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column "public.Target", :maxMarks, :integer, :default => 720
  end
end
