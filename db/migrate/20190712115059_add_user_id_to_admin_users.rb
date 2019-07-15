class AddUserIdToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :userId, :integer
  end
end
