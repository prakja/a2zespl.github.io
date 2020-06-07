class CreateUserFlashCards < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.UserFlashCard") do |t|
      t.integer :userId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :flashCardId, null: false
    end
    add_foreign_key "public.UserFlashCard", "User", column: :userId, primary_key: "id"
    add_foreign_key "public.UserFlashCard", "FlashCard", column: :flashCardId, primary_key: "id"
  end
end
