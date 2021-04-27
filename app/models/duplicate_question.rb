class DuplicateQuestion < ApplicationRecord
  has_paper_trail
  self.table_name = "DuplicateQuestion"

  scope :question_bank_duplicates, -> {
    joins(', "ChapterQuestion" cq1, "ChapterQuestion" cq2, "Question" q1, "Question" q2').where('cq1."questionId" = "DuplicateQuestion"."questionId1" and cq2."questionId" = "DuplicateQuestion"."questionId2" and cq1."chapterId" = cq2."chapterId" and "DuplicateQuestion"."questionId1" = q1."id" and q1."deleted" = false and "DuplicateQuestion"."questionId2" = q2."id" and q2."deleted" = false').distinct
  }

  scope :subject_question_bank_duplicates, ->(subjectId = nil) {
    if (subjectId.blank?)
      joins(', "ChapterQuestion" cq1, "ChapterQuestion" cq2, "Question" q1, "Question" q2').where('cq1."questionId" = "DuplicateQuestion"."questionId1" and cq2."questionId" = "DuplicateQuestion"."questionId2" and cq1."chapterId" = cq2."chapterId" and "DuplicateQuestion"."questionId1" = q1."id" and q1."deleted" = false and "DuplicateQuestion"."questionId2" = q2."id" and q2."deleted" = false and (q1."subjectId" is null and q2."subjectId" is null)').distinct
    else
      joins(', "ChapterQuestion" cq1, "ChapterQuestion" cq2, "Question" q1, "Question" q2').where('cq1."questionId" = "DuplicateQuestion"."questionId1" and cq2."questionId" = "DuplicateQuestion"."questionId2" and cq1."chapterId" = cq2."chapterId" and "DuplicateQuestion"."questionId1" = q1."id" and q1."deleted" = false and "DuplicateQuestion"."questionId2" = q2."id" and q2."deleted" = false and (q1."subjectId" = ' + subjectId.to_s + ' or q2."subjectId" = ' + subjectId.to_s + ')').distinct
    end
  }

  # assume that we want to keep quesiton 1 and remove qeustion 2
  def remove_duplicate_from_question_bank
    ActiveRecord::Base.connection.query('delete from "ChapterQuestion" where "questionId" = ' + self.questionId2.to_s + ' and "chapterId" in (select "chapterId" from "ChapterQuestion" where "questionId" in  (' + self.questionId2.to_s + ', ' + self.questionId1.to_s + ') group by "chapterId" having count(*) > 1);')
  end

  def question_bank_chapter_id
    q1Chapters = ChapterQuestion.joins(:question).where(questionId: self.questionId1)
    q2Chapters = ChapterQuestion.joins(:question).where(questionId: self.questionId2)
    chapters = q1Chapters.map(&:chapterId) & q2Chapters.map(&:chapterId)
    return chapters&.first
  end

  after_create do |dq|
    NotDuplicateQuestion.where(
      questionId1: dq.questionId1,
      questionId2: dq.questionId2
    ).delete_all
  end

  before_destroy do |dq|
    NotDuplicateQuestion.where(
      questionId1: dq.questionId1,
      questionId2: dq.questionId2
    ).first_or_create
  end

  belongs_to :question1, foreign_key: 'questionId1', class_name: "Question"
  belongs_to :question2, foreign_key: 'questionId2', class_name: "Question"
end
