class CustomerSupport < ApplicationRecord
  self.table_name = "CustomerSupport"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :admin_user, class_name: "AdminUser", foreign_key: "adminUserId", optional: true

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  # scope :my_issues, ->() {
  #   # p proc { current_admin_user.id }
  #   where(adminUserId: proc { current_admin_user.id }).where(resolved: false)
  # }

  scope :resolved, ->(resolved) {
    if resolved == "yes"
      where(resolved: true)
    else
      where(resolved: false)
    end
  }

  scope :open, -> {
    resolved("no")
  }

  scope :paid, ->(course_ids, paid) {
    if paid == "yes"
      where(UserCourse.where('"UserCourse"."userId" = "CustomerSupport"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').where(courseId: course_ids).exists)
    else
      where.not(UserCourse.where('"UserCourse"."userId" = "CustomerSupport"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').where(courseId: course_ids).exists)
    end
  }

  scope :open_paid_students, ->() {
    where(resolved: false).paid([8, 141, 20, 149, 100, 51], 'yes').order(createdAt: "DESC")
  }

  scope :open_other_students, ->() {
    where(resolved: false).paid([8, 141, 20, 149, 100, 51], 'no').order(createdAt: "DESC")
  }

  scope :seven_days_pending, ->(type) {
    where(createdAt: 7.days.ago..DateTime::Infinity.new,resolved: false,issueType: type).paid([8, 141, 20, 149, 100, 51], 'yes')
  }

  scope :five_days_pending, ->(type) {
    where(createdAt: 5.days.ago..DateTime::Infinity.new,resolved: false,issueType: type).paid([8, 141, 20, 149, 100, 51], 'yes')
  }

  scope :two_days_pending, ->(type) {
    where(createdAt: 2.days.ago..DateTime::Infinity.new,resolved: false,issueType: type).paid([8, 141, 20, 149, 100, 51], 'yes')
  }

  scope :pendrive_issue, -> { 
    open_paid_students.where(:issueType => 'Pendrive_Not_Working')
  }

  def self.ransackable_scopes(_auth_object = nil)
    [ :resolved, :not_resolved_paid, :not_resolved_not_paid ]
  end
end
