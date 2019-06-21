class User < ApplicationRecord
 self.table_name = "User"

 has_many :schedule_item_users, class_name: "ScheduleItemUser", foreign_key: "userId"
 has_one :user_profile, class_name: "UserProfile", foreign_key: "userId"
 has_many :customer_supports, class_name: "CustomerSupport", foreign_key: "userId"

 def name
  if not self.user_profile.blank? and not self.user_profile.displayName.blank?
    return self.user_profile.displayName
  else
    return 'NEET student'
  end
 end
end
