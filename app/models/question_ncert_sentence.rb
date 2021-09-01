class QuestionNcertSentence < ApplicationRecord
  self.table_name = "QuestionNcertSentence"

  nilify_blanks only: [:comment]

  belongs_to :question, foreign_key: 'questionId', class_name: 'Question', touch: true
  belongs_to :ncertSentence, foreign_key: 'ncertSentenceId', class_name: 'NcertSentence'

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def comment_without_null
    if self.comment.nil? or self.comment.length == 0
      "- Type comment here"
    else
      self.comment
    end
  end
end
