class Question < ApplicationRecord
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
end
