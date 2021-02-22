class NcertSentence < ApplicationRecord
  self.table_name = "NcertSentence"
  belongs_to :note, class_name: "Note", foreign_key: "noteId"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :section, class_name: "Section", foreign_key: "sectionId"
  has_and_belongs_to_many :questions, class_name: 'Question', join_table: 'QuestionNcertSentence', foreign_key: :ncertSentenceId, association_foreign_key: :questionId

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def fullSentenceUrl
    return '<a href="https://www.neetprep.com/notes/' + self.noteId.to_s + '#:~:text=' + self.sentenceUrl + '" target="_blank">' + self.sentence + '</a>'
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

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  # used to show actual sentence instead of #id
  def name
    return self.sentence
  end
end
