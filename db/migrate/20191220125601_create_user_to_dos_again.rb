class CreateUserToDosAgain < ActiveRecord::Migration[5.2]
  def change
    create_table "UserTodo" do |t|
      t.integer :userId, null: false
      t.integer :task_type, null: false
      t.integer :subjectId, null: false
      t.integer :chapterId, null: false

      t.float :hours, null: false
      t.integer :num_questions

      t.float :hours_taken
      t.integer :num_questions_practiced

      t.boolean :completed, default: false

      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "UserTodo", "User", column: :userId, primary_key: "id"
    add_foreign_key "UserTodo", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "UserTodo", "Subject", column: :subjectId, primary_key: "id"
  end
end
