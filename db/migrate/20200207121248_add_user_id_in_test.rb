class AddUserIdInTest < ActiveRecord::Migration[5.2]
  def change
    add_column "Test", "userId", :integer, default: nil
    add_foreign_key "Test", "User", column: :userId, primary_key: "id"
  end
end
