class CommonLeaderBoard < ApplicationRecord
  self.table_name = "CommonLeaderBoard"
  self.primary_key = "id"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  scope :paid_students, -> {where(UserCourse.where('"UserCourse"."userId" = "CommonLeaderBoard"."userId"').limit(1).arel.exists)}
end
