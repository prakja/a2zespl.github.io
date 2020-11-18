class Subject < ApplicationRecord
  has_paper_trail

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  self.table_name = "Subject"
  scope :neetprep_course, -> {where(courseId: [Rails.configuration.hinglish_full_course_id, Rails.configuration.english_full_course_id, Rails.configuration.boostup_course_id])}
  belongs_to :course, foreign_key: 'courseId', class_name: 'Course'

  has_many :subjectTopics, -> {where(deleted: false)}, foreign_key: :subjectId, class_name: 'SubjectChapter'
  has_many :topics, through: :subjectTopics

  def self.neetprep_course_subjects
    Subject.joins(:course)
    .where(courseId: [Rails.configuration.hinglish_full_course_id, Rails.configuration.english_full_course_id, Rails.configuration.boostup_course_id])
    .pluck(:name, :'Course.name', :'Subject.id', :'Course.id').map{|subject_name, course_name, subject_id| [subject_name + " - " + course_name, subject_id]}
  end

  def self.subject_names
    Subject.joins(:course)
      .where(courseId: [Rails.configuration.hinglish_full_course_id, Rails.configuration.english_full_course_id, Rails.configuration.boostup_course_id])
      .pluck(:name, :'Course.name', :'Subject.id', :'Course.id').map{|subject_name, course_name, subject_id| [subject_name + " - " + course_name, subject_id]}
  end

  def self.full_course_subject_names
    Subject.joins(:course)
      .where(courseId: [Rails.configuration.hinglish_full_course_id])
      .pluck(:name, :'Course.name', :'Subject.id', :'Course.id').map{|subject_name, course_name, subject_id| [subject_name + " - " + course_name, subject_id]}
  end
end
