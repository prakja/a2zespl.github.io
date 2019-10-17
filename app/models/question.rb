class Question < ApplicationRecord
  before_save :default_values
  def default_values
    self.options = ["(1)", "(2)", "(3)", "(4)"] if self.options.blank?
  end
  has_paper_trail
  after_commit :after_update_question, if: Proc.new { |model| model.previous_changes[:correctOptionIndex]}, on: [:update]
  after_validation :check_correct_option_of_mcq_type_question

  def check_correct_option_of_mcq_type_question
   errors.add(:correctOptionIndex, 'is required field for mcq question') if type == 'MCQ-SO' and correctOptionIndex.blank?
  end

  def test_addition_validation
   errors.add(:type, 'mcq only questions can be added in tests') if type == 'SUBJECTIVE' and !tests.blank?
  end

  def after_update_question
    if self.tests.blank?
      return
    end

    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/afterUpdateQuestion",
       body: {
         id: self.id
    })
  end

  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  default_scope {where(deleted: false)}
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  scope :subject_name, ->(subject_id) {
    joins(:topics => :subject).where(topics: {Subject: {id: subject_id}})
  }

  scope :topic, ->(topic_id) {
    joins(:topics).where("\"Topic\".\"id\"="+topic_id)
  }

  scope :difficult, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" in ('medium','difficult')")
  }

  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.hinglish_full_course_id}})}
  scope :physics_mcqs, -> {joins(:topics => :subject).where(topics: {Subject: {id: 55}})}
  scope :physics_mcqs_difficult, ->(topic_id) {
    subject_name(55).topic(topic_id).difficult
  }
  scope :chemistry_mcqs_difficult, ->(topic_id) {
    subject_name(54).topic(topic_id).difficult
  }
  scope :botany_mcqs_difficult, ->(topic_id) {
    subject_name(53).topic(topic_id).difficult
  }
  scope :zoology_mcqs_difficult, ->(topic_id) {
    subject_name(56).topic(topic_id).difficult
  }
  scope :chemistry_mcqs, -> {joins(:topics => :subject).where(topics: {Subject: {id: 54}})}
  scope :botany_mcqs, -> {joins(:topics => :subject).where(topics: {Subject: {id: 53}})}
  scope :zoology_mcqs, -> {joins(:topics => :subject).where(topics: {Subject: {id: 56}})}
  scope :test_questions, -> {joins(:tests).where("\"Test\".\"id\" IS NOT NULL")}
  scope :include_deleted, -> { unscope(:where)  }
  scope :NEET_AIPMT_PMT_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" in ('NEET', 'AIPMT', 'PMT') and \"Question\".\"deleted\"=false")}
  scope :AIIMS_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" = 'AIIMS' and \"Question\".\"deleted\"=false")}
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
  has_one :question_analytic, foreign_key: "id"
  has_many :questionTopics, foreign_key: :questionId, class_name: 'ChapterQuestion'
  has_many :topics, through: :questionTopics
  has_many :questionSubTopics, foreign_key: :questionId, class_name: 'QuestionSubTopic'
  has_many :subTopics, through: :questionSubTopics
  has_many :issues, class_name: "CustomerIssue", foreign_key: "questionId"
  # belongs_to :test, foreign_key: :testId, optional: true
  has_many :doubts, class_name: "Doubt", foreign_key: "questionId"

  has_many :questionTests, foreign_key: :questionId, class_name: 'TestQuestion', dependent: :destroy
  has_many :tests, through: :questionTests, dependent: :destroy

  def self.distinct_type
    Question.connection.select_all("select distinct \"type\" from \"Question\"")
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:subject_name]
  end
end
