class CustomerSupport < ApplicationRecord
  self.table_name = "CustomerSupport"

  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :admin_user, class_name: "AdminUser", foreign_key: "adminUserId", optional: true

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
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

  scope :not_resolved, ->() {
    where(resolved: false).order(createdAt: "DESC")
  }

  def self.ransackable_scopes(_auth_object = nil)
    [ :rsolved, :not_resolved ]
  end
end
