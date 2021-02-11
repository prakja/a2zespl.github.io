class ChapterTestQuestion < ApplicationRecord
  self.table_name = "ChapterTestQuestion"
  
  belongs_to :question, foreign_key: 'questionId', optional: true
  belongs_to :topic, foreign_key: 'chapterId', class_name: 'Topic', optional: true

  scope :physics, -> {joins(:topic).where(chapterId: Topic.physics.pluck(:id))}
  scope :chemistry, -> {joins(:topic).where(chapterId: Topic.chemistry.pluck(:id))}
  scope :botany, -> {joins(:topic).where(chapterId: Topic.botany.pluck(:id))}
  scope :zoology, -> {joins(:topic).where(chapterId: Topic.zoology.pluck(:id))}

  def id
    self.questionId
  end
end
