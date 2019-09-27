class UserVideoStat < ApplicationRecord
 self.table_name = "UserVideoStat"
 belongs_to :user, class_name: "User", foreign_key: "userId"
 belongs_to :video, class_name: "Video", foreign_key: "videoId"

 scope :paid, ->(paid, end_date) {
   if paid == "yes"
     where(UserCourse.where('"UserCourse"."userId" = "UserVideoStat"."userId" AND "UserCourse"."createdAt" >= ?', "#{end_date}").exists)
   else
     where.not(UserCourse.where('"UserCourse"."userId" = "UserVideoStat"."userId" AND "UserCourse"."createdAt" >= ?', "#{end_date}").exists)
   end
 }

 scope :paid_users_video_stats, -> {paid("yes", '2018-06-01 00:00:00 +0530')}
 scope :unpaid_users_video_stats, -> {paid("no", '2018-06-01 00:00:00 +0530')}

end
