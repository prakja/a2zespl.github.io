class CreateSelfAnalysis < ActiveRecord::Migration[5.2]
  def change
    create_table "public.SelfAnalysis" do |t|
      t.integer :targetChapterId, null: false
      t.integer :userId, null: false
      t.string :task
      t.text :type, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.datetime :from, null: false
      t.datetime :to, null: false
    end
    add_foreign_key "SelfAnalysis", "User", column: :userId, primary_key: "id"
    add_foreign_key "SelfAnalysis", "TargetChapter", column: :targetChapterId, primary_key: "id"
  end
end
