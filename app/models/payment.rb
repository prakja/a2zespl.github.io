class Payment < ApplicationRecord
  default_scope {where(paymentMode: ['kotak','cash']).or(where(status: 'responseReceivedSuccess'))}
  before_create :before_create_update_set_default_values, :setCreatedTime
  before_update :before_create_update_set_default_values, :setUpdatedTime
  scope :failed_payments, -> {unscope(:where).where.not(status: 'responseReceivedSuccess').where(paymentMode: ['paytm',nil])}

  validates_presence_of  :amount, :paymentMode

  has_paper_trail
  self.table_name = "Payment"

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def before_create_update_set_default_values
    self.revenue = self.amount
    self.gstCut = ((self.amount - self.pendriveCut) - ((self.amount - self.pendriveCut)/1.18))
    if self.paymentMode == "paytm"
      self.paytmCut = (self.amount * 0.023)
    else
      self.paytmCut = 0
    end
    self.netRevenue = (self.amount - self.paytmCut - self.gstCut - self.pendriveCut)
  end

  def self.recent_payments
    Payment.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:id)
  end

  def self.recent_payments_with_props
    Payment.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:amount, :paymentMode, :id).map{|payment_amount, payment_paymentMode, payment_id| [payment_id, payment_amount, payment_paymentMode].map(&:to_s).join(', ')}
  end

  belongs_to :course, foreign_key: "paymentForId", class_name: "Course", optional: true
  has_many :paymentCourseInvitations, foreign_key: :paymentId, class_name: 'PaymentCourseInvitation'
  has_many :courseInvitations, through: :paymentCourseInvitations
end
