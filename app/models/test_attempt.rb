class TestAttempt < ApplicationRecord
  self.table_name = "TestAttempt"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test, class_name: "Test", foreign_key: "testId"
  scope :course_id, -> (course_id) {
    joins(test: :courses).where(test: {Course: {id: course_id}})
  }

  scope :test_series, -> {course_id(8)}
end
