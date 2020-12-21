class CoachVideoDashboard < ApplicationRecord
  self.table_name = "coach_video_dashboard"

  belongs_to :video, foreign_key: 'id', optional: true
  belongs_to :topic, foreign_key: 'topic_id', class_name: 'Topic', optional: true
  belongs_to :subject, foreign_key: 'subject_id', class_name: 'Subject', optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id"
end