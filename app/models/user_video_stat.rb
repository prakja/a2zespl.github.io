class UserVideoStat < ApplicationRecord
 self.table_name = "UserVideoStat"
 belongs_to :user, class_name: "User", foreign_key: "userId"
 belongs_to :video, class_name: "Video", foreign_key: "videoId"
end
