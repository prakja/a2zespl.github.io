class LiveClass < ApplicationRecord
  self.table_name = :LiveClasses

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
