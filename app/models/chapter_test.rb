class ChapterTest < ApplicationRecord
  self.table_name = "ChapterTest"
  belongs_to :topic, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :test, class_name: "Test", foreign_key: "testId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
