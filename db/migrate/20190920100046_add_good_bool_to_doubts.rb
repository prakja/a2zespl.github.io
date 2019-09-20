class AddGoodBoolToDoubts < ActiveRecord::Migration[5.2]
  def change
    add_column "Doubt", "goodFlag", :boolean, default: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
