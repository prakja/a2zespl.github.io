class QuestionAnalytic < ApplicationRecord
  self.table_name = "QuestionAnalytics"
  self.primary_key = "id"
  belongs_to :question, class_name: "Question", foreign_key: "questionId"

  def self.distinct_difficulties
    QuestionAnalytic.connection.select_all("select distinct \"difficultyLevel\" from \"QuestionAnalytics\" where \"difficultyLevel\" is not NULL").pluck("difficultyLevel")
  end
end
