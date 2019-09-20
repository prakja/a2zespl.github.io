class Video < ApplicationRecord
  has_paper_trail

  self.table_name = "Video"
  after_commit :after_create_update_video, on: [:create]
  after_commit :after_create_update_video, if: Proc.new { |model| model.previous_changes[:url] or self.duration.blank?}, on: [:update]

  has_many :videoTopics, foreign_key: :videoId, class_name: 'ChapterVideo', dependent: :destroy
  has_many :topics, through: :videoTopics

  has_many :videoSubTopics, foreign_key: :videoId, class_name: 'VideoSubTopic'
  has_many :subTopics, through: :videoSubTopics

  has_many :issues, class_name: "CustomerIssue", foreign_key: "videoId"

  has_many :video_annotations, -> { where(annotationType: "Note") }, class_name: "VideoAnnotation", foreign_key: "videoId"
  has_many :notes, through: :video_annotations
  has_many :user_video_stats, class_name: "UserVideoStat", foreign_key: "videoId"

  scope :botany, -> {joins(:topics => :subject).where(topics: {Subject: {id:  53}})}
  scope :chemistry, -> {joins(:topics => :subject).where(topics: {Subject: {id:  54}})}
  scope :physics, -> {joins(:topics => :subject).where(topics: {Subject: {id:  55}})}
  scope :zoology, -> {joins(:topics => :subject).where(topics: {Subject: {id:  56}})}

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def after_create_update_video
    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/afterCreateUpdateVideo",
       body: {
         id: self.id,
    })
  end

  # scope :subject_name_by_id, ->(subject_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {id: subject_id}})
  # }

  # scope :subject_name_by_course, ->(course_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {courseId: course_id}})
  # }

  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.hinglish_full_course_id}})}
  scope :maths_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.hinglish_math_course_id}})}
end
