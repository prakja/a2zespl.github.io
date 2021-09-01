class QuestionNcertSentence < ApplicationRecord
  self.table_name = "QuestionNcertSentence"
  belongs_to :question, foreign_key: 'questionId', class_name: 'Question', touch: true
  belongs_to :ncertSentence, foreign_key: 'ncertSentenceId', class_name: 'NcertSentence'

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def comment_without_null
    self.comment || "- Type comment here"
  end
end
