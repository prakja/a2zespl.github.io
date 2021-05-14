class VideoSentence < ApplicationRecord
  include SEOHelper

  self.table_name = "VideoSentence"
  has_paper_trail
  belongs_to :video, class_name: "Video", foreign_key: "videoId"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :section, class_name: "Section", foreign_key: "sectionId", optional: true
  has_one :detail, class_name: "VideoSentenceDetail", foreign_key: "videoSentenceId"
  has_and_belongs_to_many :questions, class_name: 'Question', join_table: 'QuestionVideoSentence', foreign_key: :videoSentenceId, association_foreign_key: :questionId

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  scope :addDetail, ->() {
    select('"VideoSentence".*, \'\' as "sentenceContext"').preload(:detail, :chapter, :video)
  }

  scope :hinglish, ->() {
    joins(:video).where({"Video": {language: 'hinglish'}})
  }

  def sentenceHtml
    self[:sentenceHtml].blank? ? self.sentence : self[:sentenceHtml]
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def name
    self.sentence
  end

  def prevSentence
    return self.detail.prevSentence
  end

  def nextSentence
    return self.detail.nextSentence
  end

  def sentenceContext
    '[ ' + self.detail.videoName + ' ]' + self.prevSentence.to_s  + " (" + self.sentence + ") " + self.nextSentence.to_s
  end

  def playableUrlWithTimestamp
    chapter, video = self.chapter, self.video

    url = "/video-class/#{self.videoId}--#{seoUrl(video.name)}"
    domain = Rails.env == 'production' ? 'neetprep.com' : 'dev.neetprep.com'
    queryParams = "subjectId=#{chapter.subjectId}&chapterId=#{chapter.id}&currentTimeStamp=#{self.timestampStart.to_i}"

    return "https://#{domain}#{url}?#{queryParams}"
  end
end
