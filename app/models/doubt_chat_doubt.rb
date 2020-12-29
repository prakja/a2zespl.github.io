class DoubtChatDoubt < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "doubt_chat_user_id"
  belongs_to :channel, class_name: "DoubtChatChannel", foreign_key: "doubt_chat_channel_id"
  has_one :accepted_answer, class_name: "DoubtChatDoubtAnswer", foreign_key: "accepted_doubt_answer_id"
  has_many :answers, class_name: "DoubtChatDoubtAnswer", foreign_key: "doubt_chat_doubt_id"
end