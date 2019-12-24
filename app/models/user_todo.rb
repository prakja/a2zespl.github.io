class UserTodo < ApplicationRecord
  self.table_name = "UserTodo"

  belongs_to :subject, class_name: "Subject", foreign_key: "subjectId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :topic, class_name: "Topic", foreign_key: "chapterId"
  enum task_type: {
    "Studying (Video, Lecture, Live)": 0,
    "Self Study (Book, Notes)": 1,
    "Practice Question": 2,
    "Take Test": 3
  }

  scope :last_7_days, -> {
    group_by_day(:createdAt, range: 7.days.ago.midnight..Date.today.midnight)
  }

  scope :last_3_days, -> {
    group_by_day(:createdAt, range: 3.days.ago.midnight..Date.today.midnight)
  }

  scope :today, -> {
    group_by_day(:createdAt, range: 1.days.ago.midnight..Time.now)
  }

  scope :tomorrow, -> {
    group_by_day(:createdAt, range: 1.days.ago.midnight..Date.today.midnight)
  }
end
