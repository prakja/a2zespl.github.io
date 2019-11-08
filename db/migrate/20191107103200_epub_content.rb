class EpubContent < ActiveRecord::Migration[5.2]
  def change
    add_column "Note", "epubContent", :text
  end
end
