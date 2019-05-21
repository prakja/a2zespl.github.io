class Question < ApplicationRecord
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  8}})}
  scope :NEET_AIPMT_PMT_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" in ('NEET', 'AIPMT', 'PMT') and \"Question\".\"deleted\"=false")}
  scope :AIIMS_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" = 'AIIMS' and \"Question\".\"deleted\"=false")}
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
  has_many :questionTopics, -> {where(assetType: 'Question', deleted: false)}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :topics, through: :questionTopics
end
