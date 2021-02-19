class QuestionNcertSentence < ApplicationRecord
  self.table_name = "QuestionNcertSentence"
  belongs_to :question, foreign_key: 'questionId', class_name: 'Question'
  belongs_to :ncertSentence, foreign_key: 'ncertSentenceId', class_name: 'NcertSentence'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
