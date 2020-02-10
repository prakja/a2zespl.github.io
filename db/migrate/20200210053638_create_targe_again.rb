class CreateTargeAgain < ActiveRecord::Migration[5.2]
  def change
    drop_table "public.SelfAnalysis" if ActiveRecord::Base.connection.table_exists? 'SelfAnalysis'
    drop_table "public.TargetChapter" if ActiveRecord::Base.connection.table_exists? 'TargetChapter'
    drop_table "Target" if ActiveRecord::Base.connection.table_exists? 'Target'
    create_table ("public.Target") do |t|
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :userId, null: false
      t.integer :score, null: false
      t.integer :testId
      t.datetime :targetDate
      t.string :status, :default => "active"
    end
    add_foreign_key "Target", "User", column: :userId, primary_key: "id"
  end
end
