class VideoSentenceDetail < ApplicationRecord
  self.table_name = "VideoSentenceDetail"
  belongs_to :videoSentence, foreign_key: "videoSentenceId", class_name: 'VideoSentence'
end

