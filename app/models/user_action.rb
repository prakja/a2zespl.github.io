class UserAction < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "userId"
end
