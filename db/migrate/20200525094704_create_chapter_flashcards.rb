class CreateChapterFlashCards < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.ChapterFlashCard") do |t|
      t.integer :chapterId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :flashCardId, null: false
    end
  end
  add_foreign_key "TargetChapter", "Topic", column: :chapterId, primary_key: "id"
  add_foreign_key "TargetChapter", "FlashCard", column: :flashCardId, primary_key: "id"
end
