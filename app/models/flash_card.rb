class FlashCard < ApplicationRecord
  self.table_name = "FlashCard"

  has_paper_trail

  has_many :topicFlashCards, class_name: "ChapterFlashCard", foreign_key: "flashCardId", dependent: :destroy
  has_many :topics, through: :topicFlashCards

  has_many :userFlashCards, class_name: "UserFlashCard", foreign_key: "flashCardId", dependent: :destroy
  has_many :users, through: :userFlashCards

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  accepts_nested_attributes_for :topicFlashCards, allow_destroy: true
end
