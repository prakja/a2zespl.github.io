class DoubtAdmin < ApplicationRecord
  belongs_to :doubt, class_name: "Doubt", foreign_key: "doubtId"
  belongs_to :admin_user, -> {where(role: ['faculty', 'superfaculty', 'admin'])}, foreign_key: "admin_user_id"  
end
