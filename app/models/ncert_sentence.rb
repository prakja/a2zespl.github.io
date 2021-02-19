class NcertSentence < ApplicationRecord
  self.table_name = "NcertSentence"
  belongs_to :note, class_name: "Note", foreign_key: "noteId"
  belongs_to :chapter, class_name: "Topic", foreign_key: "chapterId"
  belongs_to :section, class_name: "Section", foreign_key: "sectionId"
  has_and_belongs_to_many :questions, class_name: 'Question', join_table: 'QuestionNcertSentence', foreign_key: :ncertSentenceId, association_foreign_key: :questionId

end
