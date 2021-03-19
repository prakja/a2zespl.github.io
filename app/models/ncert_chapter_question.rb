class NcertChapterQuestion < ApplicationRecord
    has_paper_trail
    self.table_name = "NcertChapterQuestion"
  
    before_create :setCreatedTime, :setUpdatedTime
    before_update :setUpdatedTime
  
    def setCreatedTime
      self.createdAt = Time.now
    end
  
    def setUpdatedTime
      self.updatedAt = Time.now
    end
  
    belongs_to :question, foreign_key: 'questionId', optional: true
    belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true
    
  end