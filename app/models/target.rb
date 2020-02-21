class Target < ApplicationRecord
  self.table_name = "Target"
  validate :check_current_active, :on => :create

  has_many :target_chapters, class_name: "TargetChapter", foreign_key: "targetId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test, class_name: "Test", foreign_key: "testId", optional: true

  def check_current_active
    p "Checking for past targets"
    current_active = Target.where(userId: self.userId, status: "active").first
    unless current_active.nil?
      errors[:attribute] << "Has another active target"
      p "Found"
      return false
    end
  end
end
