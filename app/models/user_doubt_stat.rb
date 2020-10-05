class UserDoubtStat < ApplicationRecord
  self.table_name = "UserDoubtStat"
  self.primary_key = "id"
  belongs_to :user, class_name: "User", foreign_key: "userId"
end
