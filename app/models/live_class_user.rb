class LiveClassUser < ApplicationRecord
  self.table_name = :LiveClassUser

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :user,       class_name: :User,      foreign_key: :userId,       optional: false
  belongs_to :live_class, class_name: :LiveClass, foreign_key: :liveClassId,  optional: false
end
