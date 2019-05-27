class Test < ApplicationRecord
  before_save :default_values
  def default_values
    self.ownerType = nil if self.ownerId.blank?
  end
  
  self.table_name = "Test"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  belongs_to :topic, foreign_type: 'ownerType', foreign_key: 'ownerId', optional: true
end
