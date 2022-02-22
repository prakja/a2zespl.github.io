class AddJoinUrlToLiveClass < ActiveRecord::Migration[5.2]
  def change
    add_column :LiveClass, :joinUrlWithPassword, :string, null: true, default: nil
  end
end
