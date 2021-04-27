class QuestionVideoSentence < ApplicationRecord
    self.table_name = 'QuestionVideoSentence'
    belongs_to :question, foreign_key: :questionId, class_name: :Question, touch: true
    belongs_to :VideoSentence, foreign_key: :videoSentenceId, class_name: :VideoSentence
    attribute :createdAt, :datetime, default: Time.now
    attribute :updatedAt, :datetime, default: Time.now
end
