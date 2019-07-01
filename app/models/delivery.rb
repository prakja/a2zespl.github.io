class Delivery < ApplicationRecord
  self.table_name = "Delivery"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  has_paper_trail
  after_validation :check_installment_required_dueAmount, :check_installment_required_dueDate
  validates_presence_of :deliveryType, :course, :courseValidity, :purchasedAt, :name, :email, :mobile, :address, :counselorName

  def check_installment_required_dueAmount
   errors.add(:dueAmount, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount.blank?
  end

  def check_installment_required_dueDate
   errors.add(:dueDate, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount > 0 and dueDate.blank?
  end
end
