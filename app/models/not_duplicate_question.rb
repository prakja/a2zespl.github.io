class NotDuplicateQuestion < ApplicationRecord
  has_paper_trail
  self.table_name = "NotDuplicateQuestion"

  belongs_to :question1, foreign_key: 'questionId1', class_name: "Question"
  belongs_to :question2, foreign_key: 'questionId2', class_name: "Question"
end
