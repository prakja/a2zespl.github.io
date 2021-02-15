class CreateNcertSentense < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.NcertSentence") do |t|
      t.integer :noteId
      t.integer :chapterId
      t.integer :sectionId
      t.string :sentence
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "public.NcertSentence", "Note", column: :noteId, primary_key: "id"
    add_foreign_key "public.NcertSentence", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "public.NcertSentence", "Section", column: :sectionId, primary_key: "id"
  end
end
