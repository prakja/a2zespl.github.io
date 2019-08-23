class Topic < ApplicationRecord
  has_paper_trail

  self.table_name = "Topic"
  scope :neetprep_course_id_filter, -> (course_id) {
    joins(:subject => :course).where(Subject: {courseId: course_id}).includes(:subject => :course)
  }
  # only include pcb topics for now
  scope :neetprep_course, -> {joins(:subject).where(Subject: {courseId: Rails.configuration.hinglish_full_course_id, id: [53,54,55,56]}).includes(:subject)}
  scope :neetprep_english_course, -> {joins(:subject).where(Subject: {courseId: Rails.configuration.english_full_course_id}).includes(:subject)}
  has_many :topicQuestions, foreign_key: :chapterId, class_name: 'ChapterQuestion'
  has_many :questions, through: :topicQuestions
  belongs_to :subject, foreign_key: 'subjectId', class_name: 'Subject'

  has_many :topicVideos, foreign_key: :chapterId, class_name: 'ChapterVideo'
  has_many :videos, through: :topicVideos
  has_many :doubts, class_name: "Doubt", foreign_key: "topicId"
  has_many :scheduleItems, class_name: "ScheduleItem", foreign_key: "topicId"

  has_many :topicSubjects, -> {where(deleted: false)}, foreign_key: :chapterId, class_name: 'SubjectChapter'
  has_many :subjects, through: :topicSubjects

  has_many :issues, class_name: "CustomerIssue", foreign_key: "topicId"
  has_many :subTopics, class_name: "SubTopic", foreign_key: "topicId"

  def self.distinct_name
    Topic.neetprep_course_id_filter([Rails.configuration.hinglish_full_course_id, Rails.configuration.english_full_course_id]).all().pluck("name", "id")
  end

  def self.name_with_subject
    Topic.neetprep_course_id_filter([Rails.configuration.hinglish_full_course_id, Rails.configuration.english_full_course_id]).pluck(:name, :'Subject.name', :'Course.name' , :id).map{|topic_name, subject_name, course_name, topic_id| [topic_name + " - " + subject_name + " - " + course_name, topic_id]}
  end
end
