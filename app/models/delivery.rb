class Delivery < ApplicationRecord
  self.table_name = "Delivery"
  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime
  has_paper_trail

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  after_validation :check_installment_required_dueAmount, :check_installment_required_dueDate
  validates_presence_of :deliveryType, :course, :courseValidity, :purchasedAt, :name, :email, :mobile, :address, :counselorName

  def check_installment_required_dueAmount
   errors.add(:dueAmount, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount.blank?
  end

  def check_tracking(trackingNumber)
    HTTParty.post(
      "http://track.dtdc.com/ctbs-tracking/customerInterface.tr?submitName=getLoadMovementDetails&cnNo=" + trackingNumber,
       body: {}
     )
  end

  def check_installment_required_dueDate
   errors.add(:dueDate, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount and dueAmount > 0 and dueDate.blank?
  end
end
