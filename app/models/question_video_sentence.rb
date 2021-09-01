class QuestionVideoSentence < ApplicationRecord
  self.table_name = "QuestionVideoSentence"

  nilify_blanks only: [:comment]

  has_paper_trail

  belongs_to :question, foreign_key: 'questionId', class_name: 'Question', touch: true
  belongs_to :videoSentence, foreign_key: 'videoSentenceId', class_name: 'VideoSentence'

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
