class CreateGlossaryTable < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.Glossary") do |t|
      t.string :word, :unique => true
      t.string :translation
      t.string :language
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
  end
end
