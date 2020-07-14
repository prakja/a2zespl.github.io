class AddNoteInUserFlashAndBookmark < ActiveRecord::Migration[5.2]
  def change
    add_column "UserFlashCard", :note, :string
    add_column "BookmarkQuestion", :note, :string
  end
end
