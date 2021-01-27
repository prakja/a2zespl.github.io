class AssignCountValidator < ActiveModel::Validator
  def validate(record)
    p "Checking count"
    current_unsoved_unassigned_count = Doubt.where(id: DoubtAdmin.where(admin_user_id: record.admin_user_id).pluck(:doubtId)).solved('no').count
    p "Count: " + current_unsoved_unassigned_count.to_s
    record.errors.add :base, "More than 1 unsolved doubt" if current_unsoved_unassigned_count >= 1
  end
end

class DoubtAdmin < ApplicationRecord
  validates_with AssignCountValidator

  belongs_to :doubt, class_name: "Doubt", foreign_key: "doubtId"
  belongs_to :admin_user, -> {where(role: ['faculty', 'superfaculty', 'admin'])}, foreign_key: "admin_user_id" 
end
  