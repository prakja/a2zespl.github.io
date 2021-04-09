class VideoSentence < ApplicationRecord
    self.table_name = "VideoSentence"
    belongs_to :video, class_name: "Video", foreign_key: "videoId"
    belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
    belongs_to :section, class_name: "Section", foreign_key: "sectionId"
    # has_and_belongs_to_many :questions, class_name: 'Question', join_table: 'QuestionNcertSentence', foreign_key: :ncertSentenceId, association_foreign_key: :questionId
  
    before_create :setCreatedTime, :setUpdatedTime
    before_update :setUpdatedTime
  
    def setCreatedTime
      self.createdAt = Time.now
    end
  
    def sentenceHtml
      self[:sentenceHtml].blank? ? self.sentence : self[:sentenceHtml]
    end
  
    def setUpdatedTime
      self.updatedAt = Time.now
    end
  
  
  end
  