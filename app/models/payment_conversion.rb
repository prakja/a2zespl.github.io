class PaymentConversion < ApplicationRecord
  self.table_name = "PaymentConversion"
  belongs_to :payment, class_name: "Payment", foreign_key: "paymentId"  
end
