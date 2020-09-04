class VideoLink < ApplicationRecord
  self.table_name = "VideoLink"
  has_paper_trail
  has_many :questionHints, foreign_key: 'videoLinkId', class_name: 'QuestionHint'
  belongs_to :video, foreign_key: 'videoId', class_name: 'Video'
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  validates_presence_of :name, :time, :videoId
  validate :too_close_video_links

  def too_close_video_links
    if (VideoLink.where("\"videoId\" = ? and \"time\" < ? + 30 and \"time\" > ? - 30 and \"id\" " + (id != nil ? " != " : " is not ")  + " ?", videoId, time, time, id).count > 0)
      errors.add(:time, "can't be less than 30 seconds away from any existing video links. Please set time carefully. Maybe play and pause again to set time correctly.")
    end
  end
end

