class Payment < ApplicationRecord
  after_create :create_courseInvitation
  after_update :create_courseInvitation

  default_scope {where(paymentMode: ['kotak','cash']).or(where(status: 'responseReceivedSuccess'))}
  scope :failed_payments, -> {unscope(:where).where.not(status: 'responseReceivedSuccess').where(paymentMode: ['paytm',nil])}

  validates_presence_of :course, :amount, :userName, :userEmail, :userPhone, :paymentMode, :courseExpiryAt

  def create_courseInvitation
    if self.course.blank? or self.paymentDesc.blank? or self.courseExpiryAt.blank? or self.userEmail.blank? or self.userName.blank? or self.userPhone.blank?
      return
    end

    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/sendCourseInviteFromPayment",
       body: {
         paymentId: self.id,
         courseId: self.course.id,
         amount: self.amount,
         userName: self.userName,
         userEmail: self.userEmail,
         userPhone: self.userPhone,
         paymentMode: self.paymentMode,
         paymentDesc: self.paymentDesc,
         verified: self.verified,
         courseExpiryAt: self.courseExpiryAt
    })
  end
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

  belongs_to :course, foreign_key: "paymentForId", class_name: "Course", optional: false
  has_many :paymentCourseInvitations, foreign_key: :paymentId, class_name: 'PaymentCourseInvitation'
  has_many :courseInvitations, through: :paymentCourseInvitations
end
