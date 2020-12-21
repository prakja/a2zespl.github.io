class CoachQuestionDashboard < ApplicationRecord
  self.table_name = "coach_question_dashboard"

  belongs_to :answer, foreign_key: 'id', optional: true
  belongs_to :question, class_name: "Question", foreign_key: "question_id"
  belongs_to :topic, foreign_key: 'topic_id', class_name: 'Topic', optional: true
  belongs_to :subject, foreign_key: 'subject_id', class_name: 'Subject', optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id"
end