class UserTask < ApplicationRecord
  self.table_name = "UserTask"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  before_update :setUpdatedTime

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  belongs_to :task, class_name: "Task", foreign_key: "taskId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
end