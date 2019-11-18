class AddDescriptionVideoLink < ActiveRecord::Migration[5.2]
  def change
    add_column "VideoLink", "description", :text
  end
end
