class AddColumnToUserTodo < ActiveRecord::Migration[5.2]
  def change
    add_column "UserTodo", "student_response", :string
  end
end
