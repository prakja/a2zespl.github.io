class AddColumnToUserResult < ActiveRecord::Migration[5.2]
  def change
    add_column "UserResult", :year, :integer
    add_column "UserResult", :userImage, :string
  end
end
