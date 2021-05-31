class CreateWorkLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :work_logs do |t|
      t.time :start_time
      t.time :end_time
      t.date :date
      t.integer :total_hours
      t.text :content, :null => true, :default => nil
      t.integer :admin_user_id, :null => false
      t.timestamps
    end
  end
end
