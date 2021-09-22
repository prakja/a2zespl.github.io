class CourseInvitationConversion < ApplicationRecord
  self.table_name = "CourseInvitationConversion"
  belongs_to :course_invitation, class_name: "CourseInvitation", foreign_key: "courseInvitationId", optional: true

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end
end
