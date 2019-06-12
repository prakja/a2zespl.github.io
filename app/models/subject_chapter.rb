class SubjectChapter < ApplicationRecord
  self.table_name = "SubjectChapter"
  belongs_to :subject, foreign_key: 'subjectId'
  belongs_to :topic, foreign_key: 'chapterId'
end
