class UserAction < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "userId"
  scope :free_users, -> {
    where.not(UserCourse.where('"UserCourse"."userId" = "user_actions"."userId"').exists);
  }
end
