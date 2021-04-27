class Task < ApplicationRecord
  self.table_name = "Task"

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  before_update :setUpdatedTime

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  belongs_to :topic, class_name: "Topic", foreign_key: "topicId", optional: true

  has_many :userTasks, class_name: "UserTask", foreign_key: "taskId"
end
