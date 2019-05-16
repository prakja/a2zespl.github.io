class CreateQuestionDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :question_details do |t|

      t.timestamps
    end
  end
end
