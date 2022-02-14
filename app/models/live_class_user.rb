class LiveClassUser < ApplicationRecord
  self.table_name = :LiveClassUser

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
