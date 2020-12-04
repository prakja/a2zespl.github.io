class Video < ApplicationRecord
  has_paper_trail

  nilify_blanks

  self.table_name = "Video"
  after_commit :after_create_update_video, if: Proc.new { |model| model.previous_changes[:url] or self.duration.blank?}, on: [:create, :update]

  has_many :videoTopics, foreign_key: :videoId, class_name: 'ChapterVideo', dependent: :destroy
  has_many :topics, through: :videoTopics
  has_many :videoLinks, class_name: "VideoLink", foreign_key: "videoId"

  has_many :videoSubTopics, foreign_key: :videoId, class_name: 'VideoSubTopic'
  has_many :subTopics, through: :videoSubTopics

  has_many :issues, class_name: "CustomerIssue", foreign_key: "videoId"

  has_many :video_annotations, -> { where(annotationType: "Note") }, class_name: "VideoAnnotation", foreign_key: "videoId"
  has_many :notes, through: :video_annotations
  has_many :user_video_stats, class_name: "UserVideoStat", foreign_key: "videoId"

  scope :botany, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [53, 478, 495]}})}
  scope :chemistry, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [54, 477, 494]}})}
  scope :physics, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [55, 476, 493]}})}
  scope :zoology, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [56, 479, 496]}})}

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def after_create_update_video
    p "Calling after create"
    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/afterCreateUpdateVideo",
       body: {
         id: self.id,
    })
  end

  def videoUrl
    if not self.url.blank?
      return self.url
    else
      return self.youtubeUrl
    end
  end

  scope :subject_name, ->(subject_id) {
    joins(:topics => :subject).where(topics: {Subject: {id: subject_id}})
  }

  scope :subject_names, ->(*subject_ids) {
    flatten_subject_ids = subject_ids.flatten
    joins(:topics => :subject).where(topics: {Subject: {id: flatten_subject_ids}})
  }

  scope :course_name, -> (course_id) {
    joins(:topics => :subject).where(topics: {Subject: {courseId: course_id}})
  }

  scope :course_names, ->(*course_ids) {
    flatten_course_ids = course_ids.flatten
    joins(:topics => :subject).where(topics: {Subject: {courseId: flatten_course_ids}})
  }

  # scope :subject_name_by_id, ->(subject_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {id: subject_id}})
  # }

  # scope :subject_name_by_course, ->(course_id) {
  #   joins(:topics => :subject).where(topic: {Subject: {courseId: course_id}})
  # }

  scope :neetprep_course, -> {joins(:topics => :subjects).where(topics: {Subject: {courseId: Rails.configuration.hinglish_full_course_id}}).distinct()}
  scope :maths_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.hinglish_math_course_id}}).distinct()}
  scope :boost_up_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.boostup_course_id}}).distinct()}
end
