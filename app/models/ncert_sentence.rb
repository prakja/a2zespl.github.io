class NcertSentence < ApplicationRecord
  self.table_name = "NcertSentence"
  belongs_to :note, class_name: "Note", foreign_key: "noteId"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :section, class_name: "Section", foreign_key: "sectionId"
 end