class TopicLeaderBoard < ApplicationRecord
  self.table_name = "TopicLeaderBoard"
  self.primary_key = "id"
  belongs_to :topic, class_name: "Topic", foreign_key: "topicId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  scope :paid_students, -> {where(UserCourse.where('"UserCourse"."userId" = "TopicLeaderBoard"."userId"').limit(1).arel.exists)}
end
