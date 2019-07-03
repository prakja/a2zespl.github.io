class CustomerSupport < ApplicationRecord
  self.table_name = "CustomerSupport"

  belongs_to :user, class_name: "User", foreign_key: "userId"

  scope :rsolved, ->(rsolved) {
    if rsolved == "yes"
      where(CustomerSupport.where('"CustomeSupport"."resolved" = true'))
    else
      where(CustomerSupport.where('"CustomeSupport"."resolved" = false'))
    end
  }
end
