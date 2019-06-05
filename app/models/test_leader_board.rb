class TestLeaderBoard < ApplicationRecord
  self.table_name = "TestLeaderBoard"
  belongs_to :test, class_name: "Test", foreign_key: "testId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test_attempt, class_name: "TestAttempt", foreign_key: "testAttemptId"
end
