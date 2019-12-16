class AddUniqueIndexTestQuestion < ActiveRecord::Migration[5.2]
  def change
    add_index "TestQuestion", [:testId, :questionId], unique: true
  end
end
