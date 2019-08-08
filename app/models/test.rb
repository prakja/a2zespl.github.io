class Test < ApplicationRecord
  before_save :default_values
  def default_values
    self.ownerType = nil if self.ownerId.blank?
    self.exam = nil if self.exam.blank?
  end
  
  has_paper_trail
  self.table_name = "Test"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  belongs_to :topic, foreign_type: 'ownerType', foreign_key: 'ownerId', optional: true
  has_many :testCourseTests, foreign_key: :testId, class_name: 'CourseTest'
  has_many :courses, through: :testCourseTests
  has_many :questions, class_name: "Question", foreign_key: "testId"
  has_many :test_leader_boards, class_name: "TestLeaderBoard", foreign_key: "testId"
end
