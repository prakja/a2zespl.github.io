class NotDuplicateQuestion < ApplicationRecord
  has_paper_trail
  self.table_name = "NotDuplicateQuestion"

  scope :marked_duplicate, -> {
    joins(', "DuplicateQuestion"').where('"DuplicateQuestion"."questionId1" = "NotDuplicateQuestion"."questionId1" and "DuplicateQuestion"."questionId2" = "NotDuplicateQuestion"."questionId2"').distinct
  }

  scope :subject_marked_duplicates, ->(subjectId = nil) {
    if (subjectId.blank?)
      joins(', "DuplicateQuestion", "Question" q1, "Question" q2').where('"DuplicateQuestion"."questionId1" = "NotDuplicateQuestion"."questionId1" and "DuplicateQuestion"."questionId2" = "NotDuplicateQuestion"."questionId2" and "DuplicateQuestion"."questionId1" = q1."id" and "DuplicateQuestion"."questionId2" = q2."id" and (q1."subjectId" is null and q2."subjectId" is null)').distinct
    else
      joins(', "DuplicateQuestion", "Question" q1, "Question" q2').where('"DuplicateQuestion"."questionId1" = "NotDuplicateQuestion"."questionId1" and "DuplicateQuestion"."questionId2" = "NotDuplicateQuestion"."questionId2" and "DuplicateQuestion"."questionId1" = q1."id" and "DuplicateQuestion"."questionId2" = q2."id" and (q1."subjectId" = ' + subjectId.to_s + ' or q2."subjectId" = ' + subjectId.to_s + ')').distinct
    end
  }

  def contradiction
    DuplicateQuestion.where(questionId1: self.questionId1, questionId2: self.questionId2).first
  end

  after_create do |ndq|
    DuplicateQuestion.where(
      questionId1: ndq.questionId1,
      questionId2: ndq.questionId2
    ).destroy_all
  end

  belongs_to :question1, foreign_key: 'questionId1', class_name: "Question"
  belongs_to :question2, foreign_key: 'questionId2', class_name: "Question"
end
