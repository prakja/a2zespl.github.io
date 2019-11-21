class QuestionDetail < ApplicationRecord
  self.table_name = "QuestionDetail"
  belongs_to :question, class_name: "Question", foreign_key: "questionId"
  attr_accessor :details_exam, :details_year

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  def self.distinct_year
    QuestionDetail.connection.select_all("select distinct \"year\" from \"QuestionDetail\" where \"year\" is not NULL").to_hash.pluck("year").sort
  end

  def self.distinct_exam_name
    QuestionDetail.connection.select_all("select distinct \"exam\" from \"QuestionDetail\" where \"exam\" is not NULL").to_hash.pluck("exam").sort
  end
end
