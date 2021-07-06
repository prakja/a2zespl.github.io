class VideoSentence < ApplicationRecord
  include SEOHelper

  self.table_name = "VideoSentence"
  self.sequence_name = 'public."VideoSentence_id_seq"'

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

  scope :addDetail, ->(regex_data = nil) {
    if regex_data
      select('"VideoSentence".*, \'\' as "sentenceContext", "sentence" ~ \'(?i)' + regex_data + '\' as "sentenceMatch", "sentence1" ~ \'(?i)' + regex_data + '\' as "sentence1Match"').preload(:detail, :chapter, :video)
    else
      select('"VideoSentence".*, \'\' as "sentenceContext"').preload(:detail, :chapter, :video)
    end
  }

  scope :hinglish, ->() {
    joins(:video).where({"Video": {language: 'hinglish'}})
  }

  scope :similar_to_question, ->(questionId) {

    # TODO: let's try to also show the essential_tokens in the dashboard, might be helpful to faculties
    question = Question.where(:id => questionId).where.not(:topicId => nil).first

    if question.nil?
      raise "Can't find video sentences for question with no topic"
    end

    question_text = ActionView::Base.full_sanitizer.sanitize(question.question)
    normalized_question_text = ActiveRecord::Base
      .connection.execute("select to_tsvector('context_dict', '#{question_text}'::TEXT )").to_a.first['to_tsvector']

    essential_token = normalized_question_text.scan(/\w+(?:'\w+)*/).filter { |r| r.gsub(/[^a-z ]/i, '').length > 0}
    search_query = essential_token.join(' | ')
    where(:chapterId => question.topicId).where("to_tsvector('english', sentence1) @@ to_tsquery(?) OR to_tsvector('english', sentence) @@ to_tsquery(?)", search_query, search_query)
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:similar_to_question]
  end

  def sentenceHtml
    self[:sentenceHtml].blank? ? self.transcribed_sentence : self[:sentenceHtml]
  end

  def sentence
    if self.read_attribute(:sentence).present?
      return self.read_attribute(:sentence)
    else
      return self.sentence1
    end
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def name
    self.sentence
  end

  def transcribed_sentence
    if self[:sentenceMatch]
      self.sentence
    elsif self[:sentence1Match]
      self.sentence1
    else
      self.sentence
    end
  end

  def prevSentence
    detail = self.detail
    if self[:sentenceMatch]
      detail.prevSentence
    elsif self[:sentence1Match]
      detail.prevSentence1
    else
      detail.prevSentence
    end
  end

  def nextSentence
    detail = self.detail
    if self[:sentenceMatch]
      detail.nextSentence
    elsif self[:sentence1Match]
      detail.nextSentence1
    else
      detail.nextSentence
    end
  end

  def sentenceContext
    '[ ' + self.detail.videoName + ' ]' + self.prevSentence.to_s  + " (" + self.transcribed_sentence + ") " + self.nextSentence.to_s
  end

  def playableUrlWithTimestamp
    chapter, video = self.chapter, self.video

    url = "/video-class/#{self.videoId}--#{seoUrl(video.name)}"
    domain = Rails.env == 'production' ? 'neetprep.com' : 'dev.neetprep.com'
    queryParams = "subjectId=#{chapter.subjectId}&chapterId=#{chapter.id}&currentTimeStamp=#{self.timestampStart.to_i}"

    return "https://#{domain}#{url}?#{queryParams}"
  end
end
