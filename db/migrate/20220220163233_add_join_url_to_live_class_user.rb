class AddJoinUrlToLiveClassUser < ActiveRecord::Migration[5.2]
  def change
    add_column :LiveClassUser, :joinUrl, :string, null: true, default: nil
  end
end
