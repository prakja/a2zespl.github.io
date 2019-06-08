class Question < ApplicationRecord
  before_save :default_values
  def default_values
    self.options = ["(1)", "(2)", "(3)", "(4)"] if self.options.blank?
  end
  has_paper_trail
  
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  default_scope {where(deleted: false)}
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  8}})}
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
  belongs_to :test, foreign_key: :testId, optional: true

  def self.distinct_type
    Question.connection.select_all("select distinct \"type\" from \"Question\"")
  end
end
