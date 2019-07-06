class DoubtAnswer < ApplicationRecord
  self.table_name = "DoubtAnswer"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :doubt, class_name: "Doubt", foreign_key: "doubtId"
end
