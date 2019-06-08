class CourseInvitation < ApplicationRecord
 self.table_name = "CourseInvitation"
 belongs_to :payment, foreign_key: "paymentId", class_name: "Payment", optional: true
end
