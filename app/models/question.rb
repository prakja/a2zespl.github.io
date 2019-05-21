class Question < ApplicationRecord
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  8}})}
  has_one :detail, class_name: "QuestionDetail", foreign_key: "questionId"
  has_many :questionTopics, -> {where(assetType: 'Question', deleted: false)}, foreign_key: :assetId, class_name: 'TopicAsset'
  has_many :topics, through: :questionTopics
end
