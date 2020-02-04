class Payment < ApplicationRecord
  default_scope {where(paymentMode: ['kotak','cash','paytm','paytm wallet']).or(where(status: 'responseReceivedSuccess'))}
  before_create :before_create_update_set_default_values, :setCreatedTime, :setUpdatedTime
  before_update :before_create_update_set_default_values, :setUpdatedTime
  scope :failed_payments, -> {unscope(:where).where.not(status: 'responseReceivedSuccess').where(paymentMode: ['paytm',nil])}
  scope :kotak_payments, -> {unscope(:where).where(paymentMode: 'kotak')}
  scope :paytm_payments, -> {unscope(:where).where(paymentMode: 'paytm')}
  scope :cash_payments, -> {unscope(:where).where(paymentMode: 'cash')}
  scope :direct_payments, -> {unscope(:where).where(status: 'responseReceivedSuccess').where(paymentMode: nil)}
  scope :direct_payments_test_series, -> {unscope(:where).where(status: 'responseReceivedSuccess').where(paymentMode: nil).where(paymentForId: 31)}
  scope :direct_payments_master_class, -> {unscope(:where).where(status: 'responseReceivedSuccess').where(paymentMode: nil).where(paymentForId: 253)}
  scope :direct_payments_master_class2, -> {unscope(:where).where(status: 'responseReceivedSuccess').where(paymentMode: nil).where(paymentForId: 254)}
  validates_presence_of  :amount, :paymentMode

  has_paper_trail
  self.table_name = "Payment"

  def setCreatedTime
    if createdAt.blank?
      self.createdAt = Time.now
    end
  end

  def setUpdatedTime
    if createdAt.blank?
      self.createdAt = Time.now
    end
    self.updatedAt = Time.now
  end

  def before_create_update_set_default_values
    self.revenue = self.amount
    if self.pendriveCut
      self.gstCut = ((self.amount - self.pendriveCut) - ((self.amount - self.pendriveCut)/1.18))
    end
    if self.paymentMode == "paytm"
      self.paytmCut = (self.amount * 0.023)
    else
      self.paytmCut = 0
    end
    if self.pendriveCut
      self.netRevenue = (self.amount - self.paytmCut - self.gstCut - self.pendriveCut)
    end
  end

  def self.all_payments_3_months
    Payment.unscope(:where).where(:createdAt => (Time.now - 90.day)..Time.now).where(paymentMode: ['kotak','cash','paytm wallet']).or(unscope(:where).where(status: 'responseReceivedSuccess', paymentMode: 'paytm')).pluck(:id)
  end

  def self.recent_payments_with_props
    Payment.where(:createdAt => (Time.now - 30.day)..Time.now).pluck(:amount, :paymentMode, :id).map{|payment_amount, payment_paymentMode, payment_id| [payment_id, payment_amount, payment_paymentMode].map(&:to_s).join(', ')}
  end

  belongs_to :course, foreign_key: "paymentForId", class_name: "Course", optional: true
  has_one :installment, foreign_key: "paymentId"
  has_many :paymentCourseInvitations, foreign_key: :paymentId, class_name: 'PaymentCourseInvitation'
  has_many :courseInvitations, through: :paymentCourseInvitations
end
