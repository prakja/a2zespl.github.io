class QuestionTranslation < ApplicationRecord
  self.table_name = "QuestionTranslation"

  belongs_to :ques, class_name: "Question", foreign_key: "questionId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

end
