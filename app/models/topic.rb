class Topic < ApplicationRecord
  self.table_name = "Topic"
  # only include pcb topics for now
  scope :neetprep_course, -> {joins(:subject).where(Subject: {courseId:  8, id: [53,54,55,56]})}
  has_many :topicQuestions, -> {where(assetType: 'Question', deleted: false)}, foreign_key: :topicId, class_name: 'TopicAsset'
  has_many :questions, through: :topicQuestions
  belongs_to :subject, foreign_key: 'subjectId', class_name: 'Subject'

  has_many :topicVideos, -> {where(assetType: 'Video', delete: false)}, foreign_key: :topicId, class_name: 'TopicAsset'
  has_many :videos, through: :topicVideos

  def self.distinct_name
    Topic.neetprep_course.all().pluck("name", "id")
  end
end
