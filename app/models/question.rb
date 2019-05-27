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
  has_many :questionTopics, -> {where(assetType: 'Question', deleted: false, ownerType: 'Topic')}, foreign_key: :assetId, class_name: 'TopicAsset', inverse_of: 'question'
  has_many :topics, through: :questionTopics
  has_many :questionSubTopics, -> {where(assetType: 'SubTopic', deleted: false, ownerType: 'Question')}, foreign_key: :ownerId, class_name: 'TopicAsset', inverse_of: 'questionSubTopic'
  has_many :subTopics, through: :questionSubTopics
  belongs_to :test, foreign_key: :testId, optional: true

  def self.distinct_type
    Question.connection.select_all("select distinct \"type\" from \"Question\"")
  end
end
