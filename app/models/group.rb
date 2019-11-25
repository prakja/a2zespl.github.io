class Group < ApplicationRecord
  self.table_name = "Group"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
