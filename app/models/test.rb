class Test < ApplicationRecord
  before_save :default_values
  def default_values
    self.ownerType = nil if self.ownerId.blank?
    self.exam = nil if self.exam.blank?
  end

  after_commit :after_update_test, if: Proc.new { |model| model.previous_changes[:sections]}, on: [:update]

  def after_update_test
    if self.sections.blank?
      return
    end

    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/updateTestAttempts",
       body: {
         id: self.id
    })
  end

  def questions_with_number
    questions = ""
    self.questions.order('id asc').each_with_index {|question, index|
       questions = questions + (index + 1).to_s + ' > ' + '<a target="_blank" href="/admin/questions/' + question.id.to_s + '">' + question.id.to_s + '</a><br/>'
    }
    return questions
  end

  has_paper_trail
  self.table_name = "Test"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  # belongs_to :topic, foreign_type: 'ownerType', foreign_key: 'ownerId', optional: true
  has_many :testCourseTests, foreign_key: :testId, class_name: 'CourseTest'
  has_many :courses, through: :testCourseTests

  has_many :testChapterTests, foreign_key: :testId, class_name: 'ChapterTest'
  has_many :topics, through: :testChapterTests
  # has_many :questions, class_name: "Question", foreign_key: "testId"
  has_many :test_leader_boards, class_name: "TestLeaderBoard", foreign_key: "testId"

  has_many :testQuestions, foreign_key: :testId, class_name: 'TestQuestion', dependent: :destroy
  has_many :questions, through: :testQuestions, dependent: :destroy

  scope :course_name, ->(course_id) {
    joins(:testCourseTests => :course).where(testCourseTests: {Course: {id: course_id}})
  }

  scope :neet_course, -> {course_name(8)}
  scope :test_series_2018, -> {course_name(128)}
  scope :test_series_2019, -> {course_name(148)}
end
