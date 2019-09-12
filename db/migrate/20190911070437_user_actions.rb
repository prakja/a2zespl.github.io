class UserActions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_actions do |t|
      t.integer :userId
      t.integer :count
    
      t.timestamps
    end
    add_foreign_key :user_actions, :User, column: :userId, primary_key: "id"
    add_index :user_actions, :userId, unique: true
  end
end
