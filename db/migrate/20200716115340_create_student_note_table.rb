class CreateStudentNoteTable < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.StudentNote") do |t|
      t.integer :userId, null: false
      t.integer :questionId
      t.integer :flashcardId
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
  end
end

