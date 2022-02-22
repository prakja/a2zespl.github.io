class AddJoinUrlToLiveClass < ActiveRecord::Migration[5.2]
  def change
    add_column :LiveClass, :joinUrlWithPassword, :string,   null: true,   default: nil
    add_column :LiveClass, :withRegistration,    :boolean,  null: false,  default: false
  end
end
