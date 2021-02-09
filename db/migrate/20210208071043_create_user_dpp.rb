class CreateUserDpp < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.UserDpp") do |t|
      t.integer :testId
      t.integer :userId
      t.jsonb :subTopics, :default =>  []
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "public.UserDpp", "User", column: :userId, primary_key: "id"
    add_foreign_key "public.UserDpp", "Test", column: :testId, primary_key: "id"
  end
end
