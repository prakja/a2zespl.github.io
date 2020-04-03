class AddAdminToCustomerSupport < ActiveRecord::Migration[5.2]
  def change
    add_column "CustomerSupport", "adminUserId", :integer, default: nil
    add_foreign_key "CustomerSupport", "admin_users", column: :adminUserId, primary_key: "id"
  end
end
