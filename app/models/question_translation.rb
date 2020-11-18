class QuestionTranslation < ApplicationRecord
  self.table_name = "QuestionTranslation"
  has_paper_trail

  belongs_to :ques, class_name: "Question", foreign_key: "questionId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  has_many :questionTopics, primary_key: :questionId, foreign_key: :questionId, class_name: 'ChapterQuestion'
  has_many :topics, through: :questionTopics

  scope :test_questions, ->(test_id) {
    where('"questionId" in (select "questionId" from "TestQuestion" where "testId" = ' +  test_id.to_s + ')')
  }

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:test_questions]
  end

end
