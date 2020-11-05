class TestLeaderBoard < ApplicationRecord
  self.table_name = "TestLeaderBoard"
  self.primary_key = "id"
  belongs_to :test, class_name: "Test", foreign_key: "testId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test_attempt, class_name: "TestAttempt", foreign_key: "testAttemptId"
  scope :paid_students, -> {where(UserCourse.where('"UserCourse"."userId" = "TestLeaderBoard"."userId"').limit(1).arel.exists)}
  scope :high_yield_paid_students, -> {where(UserCourse.where('"UserCourse"."userId" = "TestLeaderBoard"."userId" and "UserCourse"."courseId" in (' + Rails.config.aryan_raj_test_series_1_yr.to_s + ')').limit(1).arel.exists)}

end
