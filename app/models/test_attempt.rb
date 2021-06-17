class TestAttempt < ApplicationRecord
  self.table_name = "TestAttempt"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :test, class_name: "Test", foreign_key: "testId"
  scope :course_id, -> (course_id) {
    joins(test: :courses).where(test: {Course: {id: course_id}})
  }

  scope :test_series, -> {course_id(8)}
  scope :aryan_raj_test_series, -> {course_id(Rails.configuration.aryan_raj_test_series_1_yr)}
  scope :inspire_batch, -> {course_id(Rails.configuration.aryan_raj_test_series_2_yr)}
  scope :completed, -> {where(completed: true)}
  scope :completed_target_tests, -> {joins(:test).where('"Test"."name" ~ \'Target Test\'').completed}
  scope :completed_dpp_tests, -> {joins(:test).where('"Test"."name" ~ \'Target DPP Test\'').completed}
  scope :completed_test_series_tests, -> {test_series.completed}

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
