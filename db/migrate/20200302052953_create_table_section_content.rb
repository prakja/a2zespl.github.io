class CreateTableSectionContent < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.SectionContent") do |t|
      t.string :title, default: nil
      t.integer :contentId, null: false
      t.string :contentType, null: false
      t.integer :seqNum, default: 0
      t.integer :sectionId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "SectionContent", "Section", column: :sectionId, primary_key: "id"
  end
end
