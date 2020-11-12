class CreateTableUserResult < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.UserResult") do |t|
      t.integer :userId, null: false
      t.string :name
      t.integer :marks
      t.integer :air
      t.string :state
      t.string :city
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "UserResult", "User", column: :userId, primary_key: "id"
  end
end
