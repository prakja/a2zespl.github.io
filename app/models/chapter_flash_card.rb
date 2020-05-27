class ChapterFlashCard < ApplicationRecord
  self.table_name = "ChapterFlashCard"
  
  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  belongs_to :flash_card, foreign_key: 'flashCardId', class_name: 'FlashCard', optional: true
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
