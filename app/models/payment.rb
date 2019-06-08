class Payment < ApplicationRecord
  after_create :create_courseInvitation
  after_update :create_courseInvitation

  validates_presence_of :course, :amount, :userName, :userEmail, :userPhone, :paymentMode, :paymentDesc, :courseExpiryAt

  def create_courseInvitation
    if self.course.blank? or self.paymentDesc.blank? or self.paymentMode.blank? or self.courseExpiryAt.blank? or self.userEmail.blank? or self.userName.blank? or self.userPhone.blank?
      return
    end

    HTTParty.post(
      "http://localhost:3000/api/v1/webhook/sendCourseInviteFromPayment",
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

  belongs_to :course, foreign_key: "paymentForId", optional: false
  has_many :courseInvitations, foreign_key: "paymentId", class_name: "CourseInvitation"
end
