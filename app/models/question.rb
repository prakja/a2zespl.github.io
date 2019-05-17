class Question < ApplicationRecord
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
  # has_many :topics, through: :topic_questions
  has_and_belongs_to_many :topics, join_table: "topic_questions", foreign_key: "topic_id"
end
