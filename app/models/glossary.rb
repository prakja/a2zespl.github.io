class Glossary < ApplicationRecord
  self.table_name = "Glossary"
  
  has_many :chapter_glossaries, class_name: "ChapterGlossary", foreign_key: "glossaryId", dependent: :destroy
  has_many :chapters, through: :chapter_glossaries

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  accepts_nested_attributes_for :chapter_glossaries, allow_destroy: true
end