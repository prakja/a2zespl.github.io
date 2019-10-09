class Delivery < ApplicationRecord
  self.table_name = "Delivery"
  before_create :setCreatedTime, :setUpdatedTime, :before_create_update_set_default_values
  before_update :setUpdatedTime, :before_create_update_set_default_values
  has_paper_trail

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def before_create_update_set_default_values
    if self.course == "Full Course + Pendrive"
      self.usb = "128 GB"
    elsif self.course == "Physics Course + Pendrive"
      self.usb = "32 GB + 16 GB"
    elsif self.course == "Chemistry Course + Pendrive"
      self.usb = "32 GB"
    elsif self.course == "Biology Course + Pendrive"
      self.usb = "32 GB + 16 GB"
    elsif self.course == "Physics + Biology + Pendrive"
      self.usb = "64 GB + 32 GB"
    elsif self.course == "Chemistry + Biology + Pendrive"
      self.usb = "64 GB + 16 GB"
    elsif self.course == "Physics + Chemistry + Pendrive"
      self.usb = "64 GB + 16 GB"
    elsif self.course == "Dongle Only"
      self.usb = ""
    elsif self.course == "9th Class Course + Pendrive"
      self.usb = "32 GB"
    elsif self.course == "10th Class Course + Pendrive"
      self.usb = "64 GB"
    end
  end

  after_validation :check_installment_required_dueAmount, :check_installment_required_dueDate
  validates_presence_of :deliveryType, :course, :courseValidity, :purchasedAt, :name, :email, :mobile, :address, :counselorName

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of :mobile, :with =>  /\d[0-9]\)*\z/
  validates :mobile, :numericality => true, :length => { :minimum => 10, :maximum => 13 }

  def check_installment_required_dueAmount
   errors.add(:dueAmount, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount.blank?
  end

  def check_tracking(trackingNumber)
    HTTParty.post(
      "http://track.dtdc.com/ctbs-tracking/customerInterface.tr?submitName=getLoadMovementDetails&cnNo=" + trackingNumber,
       body: {}
     )
  end

  def check_duplicate(email, mobile, createDate)
    rowCount = Delivery.where(:createdAt => (createDate - 30.day)..createDate, :email => email, :mobile => mobile).where.not(deliveryType: 'installment').count
    if rowCount > 1
      return "Duplicate"
    else
      return ""
    end
  end

  def check_installment_required_dueDate
   errors.add(:dueDate, 'is required field for installment delivery') if deliveryType == 'installment' and dueAmount and dueAmount > 0 and dueDate.blank?
  end
end
