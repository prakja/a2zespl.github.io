class AddUniqueIndexToWorkLogs < ActiveRecord::Migration[5.2]
  def change
    add_index :work_logs, [:date, :admin_user_id], unique: true
  end
end
