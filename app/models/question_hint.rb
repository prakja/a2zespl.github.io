class QuestionHint < ApplicationRecord
  self.table_name = "QuestionHint"

  belongs_to :question, class_name: "Question", foreign_key: "questionId"

  belongs_to :course, class_name: "Course", foreign_key: "courseId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

end
