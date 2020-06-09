class CreateActiveFlashCardChapters < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.ActiveFlashCardChapter") do |t|
      t.integer :chapterId
    end
  end
end
