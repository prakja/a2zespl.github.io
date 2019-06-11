class PaymentCourseInvitation < ApplicationRecord
  self.table_name = 'PaymentCourseInvitation'
  belongs_to :payment, foreign_key: 'paymentId'
  belongs_to :courseInvitation, foreign_key: 'courseInvitationId', class_name: 'CourseInvitation'
end
