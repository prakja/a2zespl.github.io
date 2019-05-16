class QuestionDetail < ApplicationRecord
  self.table_name = "QuestionDetail"
  belongs_to :question, class_name: "Question", foreign_key: "questionId"
end
