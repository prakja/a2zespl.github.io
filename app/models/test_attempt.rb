class TestAttempt < ApplicationRecord
  self.table_name = "TestAttempt"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test, class_name: "Test", foreign_key: "testId"
  scope :course_id, -> (course_id) {
    joins(test: :courses).where(test: {Course: {id: course_id}})
  }

  scope :test_series, -> {course_id(8)}
  scope :aryan_raj_test_series, -> {course_id(Rails.configuration.aryan_raj_test_series_1_yr)}

  scope :score_gte, -> (score){
    TestAttempt.where("(\"result\"->>'totalMarks')::INTEGER >= ?", score)
  }

  scope :score_lt, -> (score){
    TestAttempt.where("(\"result\"->>'totalMarks')::INTEGER < ?", score)
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:score_gte, :score_lt]
  end
end
