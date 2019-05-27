class Test < ApplicationRecord
  self.table_name = "Test"
  belongs_to :topic, foreign_type: 'Topic', foreign_key: 'ownerId', optional: true
end
