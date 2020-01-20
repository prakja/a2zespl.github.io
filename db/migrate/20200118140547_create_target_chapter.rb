class CreateTargetChapter < ActiveRecord::Migration[5.2]
  def change
    create_table "TargetChapter" do |t|
      t.integer :subjectId, null: false
      t.integer :chapterId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :goal, null: false
      t.datetime :expiryAt, null: false
      t.boolean :active, default: true
      t.integer :userId, null: false
    end
    add_foreign_key "TargetChapter", "User", column: :userId, primary_key: "id"
    add_foreign_key "TargetChapter", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "TargetChapter", "Subject", column: :subjectId, primary_key: "id"
  end
end
