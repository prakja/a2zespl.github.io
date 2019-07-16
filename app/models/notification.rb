class Notification < ApplicationRecord
  self.table_name = "Notification"
  belongs_to :user, class_name: "User", foreign_key: "userId"
end
