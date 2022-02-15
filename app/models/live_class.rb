class LiveClass < ApplicationRecord
  self.table_name = :LiveClasses

  has_many :couse_live_classes, foreign_key: :liveClassId, dependent: :destroy, class_name: :CourseLiveClass
  has_many :courses, through: :couse_live_classes,         dependent: :destroy 

  has_many :live_class_user, foreign_key: :liveClassId, class_name: :LiveClassUser
  has_many :users, through: :live_class_user, dependent: :destroy

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  accepts_nested_attributes_for :couse_live_classes, allow_destroy: true
end
