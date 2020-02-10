class CreateTargetChapters < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.TargetChapter") do |t|
      t.integer :chapterId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :targetId, null: false
      t.integer :hours, null: false
      t.boolean :revision, default: false
    end
    add_foreign_key "TargetChapter", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "TargetChapter", "Target", column: :targetId, primary_key: "id"
  end
end
