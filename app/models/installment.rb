class Installment < ApplicationRecord
  self.table_name = "Installment"
  self.primary_key = "id"
  validates_presence_of :paymentId

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :payment, foreign_key: "paymentId", class_name: "Payment"
end
