class CreateChapterFlashcards < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.ChapterFlashCard") do |t|
      t.integer :chapterId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :flashCardId, null: false
    end
    add_foreign_key "public.ChapterFlashCard", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "public.ChapterFlashCard", "FlashCard", column: :flashCardId, primary_key: "id"
  end
end
