class UserProfileAnalytic < ApplicationRecord
  self.table_name = "UserProfileAnalytic"
  belongs_to :user, class_name: "User", foreign_key: "userId"
end
