class FlashCard < ApplicationRecord
  self.table_name = "FlashCard"

  has_many :topicFlashCards, class_name: "ChapterFlashCard", foreign_key: "flashCardId", dependent: :destroy
  has_many :topics, through: :topicFlashCards

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
