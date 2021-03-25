class NcertChapterQuestion < ApplicationRecord
  self.table_name = "NcertChapterQuestion"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  belongs_to :ncertQuestion, foreign_key: 'questionId', class_name: 'Question', optional: true
  belongs_to :chapter , foreign_key: 'chapterId', class_name: 'Topic', optional: true

end
