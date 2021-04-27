class CreateQuestionVideoSentence < ActiveRecord::Migration[5.2]
  def change
    create_table :QuestionVideoSentence do |t|
      t.integer :questionId
      t.integer :videoSentenceId
      t.timestamp
    end
    add_foreign_key :QuestionVideoSentence, :Question, column: :questionId, primary_key: "id"
    add_foreign_key :QuestionVideoSentence, :VideoSentence, column: :videoSentenceId, primary_key: "id"
  end
end
