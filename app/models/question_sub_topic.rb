class QuestionSubTopic < ApplicationRecord
  self.table_name = "QuestionSubTopic"
  #TODO: optional: true shouldn't have been required but has to added as on question create page has options for adding subtopics. However on validity check of question subtopic object, error is thrown saying question must exist. However question is yet to be created and till now only question object and associated question subtopics objects are created. Though, there shouldn't be any database integrity issue and correct foreign key and not null checks are added
  belongs_to :question, foreign_key: 'questionId', class_name: 'Question', touch: true, optional: true
  belongs_to :subTopic, foreign_key: 'subTopicId', class_name: 'SubTopic'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
