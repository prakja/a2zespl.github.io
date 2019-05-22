class Question < ApplicationRecord
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  default_scope {where(deleted: false)}
  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  8}})}
  scope :include_deleted, -> { unscope(:where)  }
  scope :NEET_AIPMT_PMT_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" in ('NEET', 'AIPMT', 'PMT') and \"Question\".\"deleted\"=false")}
  scope :AIIMS_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" = 'AIIMS' and \"Question\".\"deleted\"=false")}
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
  has_many :questionTopics, -> {where(assetType: 'Question', deleted: false, ownerType: 'Topic')}, foreign_key: :assetId, class_name: 'TopicAsset', inverse_of: 'question'
  has_many :topics, through: :questionTopics
  has_many :questionSubTopics, -> {where(assetType: 'SubTopic', deleted: false, ownerType: 'Question')}, foreign_key: :ownerId, class_name: 'TopicAsset', inverse_of: 'questionSubTopic'
  has_many :subTopics, through: :questionSubTopics
end
