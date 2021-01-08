class UserCourse < ApplicationRecord
  self.table_name = "UserCourse"
  has_paper_trail
  belongs_to :course, foreign_key: "courseId", class_name: "Course", optional: false
  belongs_to :invitation, foreign_key: "invitationId", class_name: "CourseInvitation", optional: true
  belongs_to :user, foreign_key: "userId", class_name: "User"
  # belongs_to :courseInvitation, foreign_key: "invitationId", class_name: "CourseInvitation", optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  scope :active, ->() {
    where('"UserCourse"."startedAt" <= current_timestamp and "UserCourse"."expiryAt" > current_timestamp')
  }

  scope :inactive, ->() {
    where('"UserCourse"."startedAt" <= current_timestamp and "UserCourse"."expiryAt" < current_timestamp')
  }

  scope :active_trial, ->() {
    with_all_course_count.where('"UserCourse"."startedAt" <= current_timestamp and "UserCourse"."expiryAt" > current_timestamp and "UserCourse"."courseCount" = 1')
  }

  scope :inactive_trial, ->() {
    with_all_course_count.where('"UserCourse"."startedAt" <= current_timestamp and "UserCourse"."expiryAt" < current_timestamp and "UserCourse"."courseCount" = 1')
  }

  scope :achiever_batch_access_only, ->() {
    with_course_count.where('"UserCourse"."courseCount" = 1 and "UserCourse"."courseId" = 287');
  }

  scope :inspire_batch_access_only, ->() {
    with_course_count.where('"UserCourse"."courseCount" = 1 and "UserCourse"."courseId" = 386');
  }

  scope :active_trial_courses, ->() {
    UserCourse.active_trial.duration_lt_5_days
  }

  scope :inactive_trial_courses, ->() {
    UserCourse.inactive_trial.duration_lt_5_days
  }

  scope :duration_lt_5_days, -> (){
    where('"UserCourse"."expiryAt" - "UserCourse"."startedAt" <  interval \'5 days\'')
  }

  scope :duration_10_days, -> (){
    where('"UserCourse"."expiryAt" - "UserCourse"."startedAt" >  interval \'10 days\'')
  }

  private
  def self.with_all_course_count
    from <<-SQL.strip_heredoc
    (SELECT *, count(*) OVER (
    PARTITION BY "userId"
    ) as "courseCount" FROM "UserCourse") AS "UserCourse"
    SQL
  end

  def self.with_course_count
    from <<-SQL.strip_heredoc
    (SELECT *, count(*) OVER (
    PARTITION BY "userId"
    ) as "courseCount" FROM "UserCourse" where "courseId" in (287, 386, 8, 141, 18, 19, 20, 271, 272, 273) and ("startedAt" - "expiryAt" > interval '10 days') and "expiryAt" > current_timestamp) AS "UserCourse"
    SQL
  end

end
