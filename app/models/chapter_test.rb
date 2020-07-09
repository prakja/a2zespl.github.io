class ChapterTest < ApplicationRecord
  self.table_name = "ChapterTest"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId", optional: true
  belongs_to :test, class_name: "Test", foreign_key: "testId", optional: true

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
