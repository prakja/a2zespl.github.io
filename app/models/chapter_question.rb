class ChapterQuestion < ApplicationRecord
  has_paper_trail
  self.table_name = "ChapterQuestion"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def self.main_course_chapter_update!(questionId, newChapterId)
    deleted = ChapterQuestion.where(questionId: questionId, chapterId: (Topic.neetprep_course.pluck(:id) - [newChapterId])).delete_all
    if not ChapterQuestion.where(questionId: questionId, chapterId: newChapterId).exists? and deleted > 0
      ChapterQuestion.create!(questionId: questionId, chapterId: newChapterId)
    end
  end

  def update_chapter!(newId)
    newChapterId = DuplicateChapter.newDuplicateChapter(self.chapterId, newId)
    if not DuplicateChapter.duplicate?(self.chapterId, newId) and newChapterId.present?
      if ChapterQuestion.where(questionId: self.questionId, chapterId: newChapterId).exists?
        self.destroy
      else
        ActiveRecord::Base.connection.execute('Update "ChapterQuestion" set "chapterId" = "newDuplicateChapter"(' + self.chapterId.to_s + ", " + newId.to_s + ') where "id" = ' + self.id.to_s + ' and not exists (select * From "ChapterQuestion" where "chapterId" = "newDuplicateChapter"(' + self.chapterId.to_s + ", " + newId.to_s + ') and "questionId" = ' + self.questionId.to_s + ')')
        ChapterQuestion.where(questionId: self.questionId, chapterId: self.chapterId).delete_all;
      end
    end
  end

  belongs_to :question, foreign_key: 'questionId', optional: true, touch: true
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
