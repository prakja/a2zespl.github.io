class NcertSentence < ApplicationRecord
  self.table_name = "NcertSentence"
  belongs_to :note, class_name: "Note", foreign_key: "noteId"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :section, class_name: "Section", foreign_key: "sectionId"
  has_and_belongs_to_many :questions, class_name: 'Question', join_table: 'QuestionNcertSentence', foreign_key: :ncertSentenceId, association_foreign_key: :questionId
  has_one :detail, class_name: "NcertSentenceDetail", foreign_key: "ncertSentenceId"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  scope :addDetail, ->() {
    select('"NcertSentence".*, \'\' as "sentenceContext"').preload(:detail, :chapter, :note, :section)
  }

  def setCreatedTime
    self.createdAt = Time.now
  end

  def sentenceHtml
    self[:sentenceHtml].blank? ? self.sentence : self[:sentenceHtml]
  end

  def fullSentenceUrl
    return '<a href="https://www.neetprep.com/notes/' + self.noteId.to_s + '#:~:text=' + self.sentenceUrl + '" target="_blank"><span>' + (self.sentenceHtml) + '</span></a>'
  end

  ransacker :questions_count do
    Arel.sql('(SELECT COUNT("QuestionNcertSentence"."id") FROM "QuestionNcertSentence" WHERE "QuestionNcertSentence"."ncertSentenceId" = "NcertSentence"."id")')
  end

  def sentenceUrl
    ncertSentence = self.sentence
    sentenceStart = ncertSentence
    sentenceEnd = nil
    if ncertSentence.include? ','
      sentenceStart = ncertSentence[0, ncertSentence.index(',')]
      sentenceEnd = ncertSentence[(ncertSentence.rindex(',')+1)..]
    end
    return (sentenceEnd ? sentenceStart : sentence) + (sentenceEnd ? ',' + sentenceEnd : "");
  end

  def prevSentence
    return self.detail.prevSentence
  end

  def nextSentence
    return self.detail.nextSentence
  end

  def sentenceContext
    self.prevSentence.to_s  + " (" + self.sentence + ") " + self.nextSentence.to_s
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  # used to show actual sentence instead of #id
  def name
    return self.sentence
  end
end
