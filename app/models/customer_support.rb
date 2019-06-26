class CustomerSupport < ApplicationRecord
  self.table_name = "CustomerSupport"

  belongs_to :user, class_name: "User", foreign_key: "userId"
end
