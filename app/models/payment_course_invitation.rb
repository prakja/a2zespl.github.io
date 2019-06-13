class PaymentCourseInvitation < ApplicationRecord
  self.table_name = 'PaymentCourseInvitation'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  belongs_to :payment, foreign_key: 'paymentId', class_name: 'Payment', optional: true
  belongs_to :courseInvitation, foreign_key: 'courseInvitationId', class_name: 'CourseInvitation', optional: true
end
