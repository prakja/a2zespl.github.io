class CustomerSupport < ApplicationRecord
  self.table_name = "CustomerSupport"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :admin_user, class_name: "AdminUser", foreign_key: "adminUserId", optional: true

  # scope :my_issues, ->() {
  #   # p proc { current_admin_user.id }
  #   where(adminUserId: proc { current_admin_user.id }).where(resolved: false)
  # }

  scope :rsolved, ->(rsolved) {
    if rsolved == "yes"
      where(CustomerSupport.where('"CustomeSupport"."resolved" = true'))
    else
      where(CustomerSupport.where('"CustomeSupport"."resolved" = false'))
    end
  }

  # def self.ransackable_scopes(_auth_object = nil)
  #   [ :my_issues ]
  # end
end
