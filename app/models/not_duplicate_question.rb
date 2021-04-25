class NotDuplicateQuestion < ApplicationRecord
  has_paper_trail
  self.table_name = "NotDuplicateQuestion"

  scope :marked_duplicate, -> {
    joins(', "DuplicateQuestion"').where('"DuplicateQuestion"."questionId1" = "NotDuplicateQuestion"."questionId1" and "DuplicateQuestion"."questionId2" = "NotDuplicateQuestion"."questionId2"').distinct
  }

  def contradiction
    DuplicateQuestion.where(questionId1: self.questionId1, questionId2: self.questionId2).first
  end

  belongs_to :question1, foreign_key: 'questionId1', class_name: "Question"
  belongs_to :question2, foreign_key: 'questionId2', class_name: "Question"
end
