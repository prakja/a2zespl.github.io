class AddTodoColumnToUserTodo < ActiveRecord::Migration[5.2]
  def change
    add_column "UserTodo", "todo", :string
  end
end
