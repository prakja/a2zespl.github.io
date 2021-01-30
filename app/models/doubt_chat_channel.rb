class DoubtChatChannel < ApplicationRecord
  has_many :doubts, class_name: "DoubtChatDoubt", foreign_key: "doubt_chat_channel_id"

  def self.channel_chapter_name
    chapter_name = []
    DoubtChatChannel.all.each do |channel|
      chapter_name << channel.name.split(' - ')[1]
    end
    return chapter_name
  end
end