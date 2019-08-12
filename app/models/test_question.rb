class TestQuestion < ApplicationRecord
  self.table_name = "TestQuestion"
  belongs_to :question, foreign_key: 'questionId', optional: true
  belongs_to :test, foreign_key: 'testId', class_name: 'Test', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
