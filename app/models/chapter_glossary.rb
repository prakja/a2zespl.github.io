class ChapterGlossary < ApplicationRecord
  self.table_name = "ChapterGlossary"
  
  belongs_to :glossary, foreign_key: 'glossary', class_name: 'Glossary', optional: true
  belongs_to :chapter, foreign_key: 'chapterId', class_name: 'Topic', optional: true

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end