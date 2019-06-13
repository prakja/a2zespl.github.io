class Payment < ApplicationRecord
  default_scope {where(paymentMode: ['kotak','cash']).or(where(status: 'responseReceivedSuccess'))}
  scope :failed_payments, -> {unscope(:where).where.not(status: 'responseReceivedSuccess').where(paymentMode: ['paytm',nil])}

  validates_presence_of  :amount, :paymentMode

  has_paper_trail
  self.table_name = "Payment"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def self.recent_payments
    Payment.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:id)
  end

  def self.recent_payments_with_props
    Payment.where(:createdAt => (Time.now - 7.day)..Time.now).pluck(:amount, :paymentMode, :id).map{|payment_amount, payment_paymentMode, payment_id| ["#" + payment_id.to_s + " - " + payment_amount.to_s + " - " + payment_paymentMode, payment_id]}
  end

  belongs_to :course, foreign_key: "paymentForId", class_name: "Course", optional: true
  has_many :paymentCourseInvitations, foreign_key: :paymentId, class_name: 'PaymentCourseInvitation'
  has_many :courseInvitations, through: :paymentCourseInvitations
end
