class AddColumnToChapterGlossary < ActiveRecord::Migration[5.2]
  def change
    add_column "ChapterGlossary", :frequency, :integer, :default => nil
  end
end
