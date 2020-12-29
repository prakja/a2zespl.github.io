class DoubtChatDoubtAnswer < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "doubt_chat_user_id"
  belongs_to :doubts, class_name: "DoubtChatDoubt", foreign_key: "doubt_chat_doubt_id"
end