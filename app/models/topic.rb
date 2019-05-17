class Topic < ApplicationRecord
 self.table_name = "Topic"
  # has_many :questions, through: :topic_questions
  has_and_belongs_to_many :questions, join_table: "topic_questions", foreign_key: "topic_id"
end