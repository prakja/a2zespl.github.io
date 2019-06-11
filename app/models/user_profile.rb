class UserProfile < ApplicationRecord
 self.table_name = "UserProfile"

 belongs_to :user, class_name: "User", foreign_key: "userId"
end
