class CreateTableSection < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.Section") do |t|
      t.string :name, null: false
      t.integer :chapterId, null: false
      t.integer :seqNum, default: 0
      t.string :ncertName, default: nil
      t.string :ncertURL, default: nil
      t.string :ncertSectionLink, default: nil
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "Section", "Topic", column: :chapterId, primary_key: "id"
  end
end
