class Test < ApplicationRecord
  self.table_name = "Test"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  belongs_to :topic, foreign_type: 'Topic', foreign_key: 'ownerId', optional: true
end
