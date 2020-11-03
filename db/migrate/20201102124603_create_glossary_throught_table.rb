class CreateGlossaryThroughtTable < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.ChapterGlossary") do |t|
      t.integer :chapterId, foreign_key: true
      t.integer :glossaryId, foreign_key: true
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "ChapterGlossary", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "ChapterGlossary", "Glossary", column: :glossaryId, primary_key: "id"
  end
end
