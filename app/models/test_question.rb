class TestQuestion < ApplicationRecord
  self.table_name = "TestQuestion"
  self.sequence_name = "\"TestQuestion_id_seq\""
  has_paper_trail on: [:destroy]
  belongs_to :question, foreign_key: 'questionId', optional: true
  belongs_to :question_id, foreign_key: 'questionId', class_name: 'Question', optional: true, touch: true
  belongs_to :test, foreign_key: 'testId', class_name: 'Test', optional: true
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  after_create :setTestNumQuestions
  after_destroy :setTestNumQuestions

  def setTestNumQuestions 
    test = self.test
    if test.numQuestions.blank? or test.numQuestions < test.questions.count
      test.numQuestions = test.questions.count
      test.save
    end
  end
end
