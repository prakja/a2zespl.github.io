class Video < ApplicationRecord
  has_paper_trail

  self.table_name = "Video"

  has_many :videoTopics, foreign_key: :videoId, class_name: 'ChapterVideo'
  has_many :topics, through: :videoTopics
  
  has_many :videoSubTopics, foreign_key: :videoId, class_name: 'VideoSubTopic'
  has_many :subTopics, through: :videoSubTopics

  has_many :issues, class_name: "CustomerIssue", foreign_key: "videoId"

  has_many :video_annotations, class_name: "VideoAnnotation", foreign_key: "videoId"

  scope :botany, -> {joins(:topics => :subject).where(topics: {Subject: {id:  53}})}
  scope :chemistry, -> {joins(:topics => :subject).where(topics: {Subject: {id:  54}})}
  scope :physics, -> {joins(:topics => :subject).where(topics: {Subject: {id:  55}})}
  scope :zoology, -> {joins(:topics => :subject).where(topics: {Subject: {id:  56}})}

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  # scope :subject_name_by_id, ->(subject_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {id: subject_id}})
  # }

  # scope :subject_name_by_course, ->(course_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {courseId: course_id}})
  # }
  
  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  8}})}
  scope :maths_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId:  115}})}


end
