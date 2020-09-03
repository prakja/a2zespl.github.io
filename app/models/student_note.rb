class StudentNote < ApplicationRecord
  self.table_name = "StudentNote"
  belongs_to :note, foreign_key: "noteId", class_name: "Note", optional: true
  belongs_to :question, foreign_key: "questionId", class_name: "Question", optional: true
  belongs_to :flashCard, foreign_key: "flashcardId", class_name: "Question", optional: true
  belongs_to :user, foreign_key: "userId", class_name: "User"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  scope :questionNotes, ->() {
    where('"questionId" is not null')
  }
  scope :flashCardNotes, ->() {
    where('"flashcardId" is not null')
  }
  scope :ncertNotes, ->() {
    where('"noteId" is not null')
  }
end
