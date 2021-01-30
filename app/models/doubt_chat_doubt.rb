class DoubtChatDoubt < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "doubt_chat_user_id"
  belongs_to :channel, class_name: "DoubtChatChannel", foreign_key: "doubt_chat_channel_id"
  has_one :accepted_answer, class_name: "DoubtChatDoubtAnswer", foreign_key: "accepted_doubt_answer_id"
  has_many :answers, class_name: "DoubtChatDoubtAnswer", foreign_key: "doubt_chat_doubt_id"

  def self._not_exists(scope)
    "NOT #{_exists(scope)}"
  end
  
  def self._exists(scope)
    "EXISTS(#{scope.to_sql})"
  end

  scope :unsoved_older_than_one_day, -> {
    where(created_at: Time.now-100.days..Time.now-1.day, accepted_doubt_answer_id: nil).where(_not_exists(DoubtChatDoubtAnswer.where('"doubt_chat_doubt_answers"."doubt_chat_doubt_id"="doubt_chat_doubts"."id"')))
  }

  scope :subject_doubts, ->(name) {
    joins(:channel).where('"doubt_chat_channels"."name" LIKE ?', name + '%')
  }
  
  scope :chapter_doubts, ->(name) {
    joins(:channel).where('"doubt_chat_channels"."name" LIKE ?', '% - ' + name)
  }

  scope :physics_doubts, -> { subject_doubts('Phy')}
  scope :chemistry_doubts, -> { subject_doubts('Chem')}
  scope :biology_doubts, -> { subject_doubts('Bio')}

  def self.ransackable_scopes(_auth_object = nil)
    [:older_than_one_day, :subject_doubts, :chapter_doubts]
  end
end