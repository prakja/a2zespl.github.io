class CreateFlashcards < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.FlashCard") do |t|
      t.string :content
      t.string :title
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
  end
end
