class DoubtChatChannel < ApplicationRecord
  has_many :doubts, class_name: "DoubtChatDoubt", foreign_key: "doubt_chat_channel_id"
end