class PaymentConversion < ApplicationRecord
  self.table_name = "PaymentConversion"
  belongs_to :payment, class_name: "Payment", foreign_key: "paymentId"  

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
