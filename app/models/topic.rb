class Topic < ApplicationRecord
  self.table_name = "Topic"
  scope :neetprep_course, -> {joins(:subject).where(Subject: {courseId:  8})}
  has_many :topicQuestions, -> {where(assetType: 'Question', deleted: false)}, foreign_key: :topicId, class_name: 'TopicAsset'
  has_many :questions, through: :topicQuestions
  belongs_to :subject, foreign_key: 'subjectId', class_name: 'Subject'
end
