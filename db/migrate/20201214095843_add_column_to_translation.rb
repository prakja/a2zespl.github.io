class AddColumnToTranslation < ActiveRecord::Migration[5.2]
  def change
    add_column "QuestionTranslation", :newQuestionId, :integer
  end
end
