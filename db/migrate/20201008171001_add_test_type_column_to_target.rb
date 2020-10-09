class AddTestTypeColumnToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column "Target", "testType", :string
  end
end
