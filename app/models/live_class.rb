class LiveClass < ApplicationRecord
  self.table_name = :LiveClass

  has_many :couse_live_classes, foreign_key: :liveClassId, dependent: :destroy, class_name: :CourseLiveClass
  has_many :courses, through: :couse_live_classes,         dependent: :destroy 

  has_many :live_class_user, foreign_key: :liveClassId, class_name: :LiveClassUser
  has_many :users, through: :live_class_user, dependent: :destroy

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  accepts_nested_attributes_for :couse_live_classes, allow_destroy: true

  validates :startTime, presence: true
  validates :endTime,   presence: true

  validate :duration_cannot_be_negative

  def duration_cannot_be_negative
    if self.duration < 0
      errors.add(:endTime, "can't be in the past")
    end
  end

  def room_id
    # get room_id from base64 of room name and remove all special characters
    Base64.encode64(self.roomName).gsub(/[^0-9A-Za-z]/, '')
  end

  def duration
    ((self.endTime - self.startTime) / 1.minutes).to_i
  end
end
