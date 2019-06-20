class Delivery < ApplicationRecord
  self.table_name = "Delivery"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  has_paper_trail
end
