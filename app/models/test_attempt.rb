class TestAttempt < ApplicationRecord
 self.table_name = "TestAttempt"

 belongs_to :user, class_name: "User", foreign_key: "userId"
end
