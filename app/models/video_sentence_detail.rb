class VideoSentenceDetail < ApplicationRecord
  self.table_name = "VideoSentenceDetail"
  self.primary_key = "id"
  belongs_to :videoSentence, foreign_key: "videoSentenceId", class_name: 'VideoSentence'
end

