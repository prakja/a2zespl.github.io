class DropContrainNotNullUserTodo < ActiveRecord::Migration[5.2]
  def change
    change_column_null("UserTodo", "subjectId", true)
    change_column_null("UserTodo", "chapterId", true)
  end
end
