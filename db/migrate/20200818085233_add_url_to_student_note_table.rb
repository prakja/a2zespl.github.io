class AddUrlToStudentNoteTable < ActiveRecord::Migration[5.2]
  def change
    add_column "StudentNote", "chapterId", :integer, default: nil
    add_column "StudentNote", "url", :string, default: nil
  end
end
