class UserTodo < ApplicationRecord
  self.table_name = "UserTodo"

  belongs_to :subject, class_name: "Subject", foreign_key: "subjectId"
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :topic, class_name: "Topic", foreign_key: "chapterId"

  enum task_type: {
    "Studying (Video, Lecture, Live)": 0,
    "Self Study (Book, Notes)": 1,
    "Practice Question": 2,
    "Take Test": 3,
    "Others": 4
  }

  scope :my_students, ->(admin_user) {
    UserTodo.where(['"userId" IN (?)', AdminUser.find(admin_user).coachStudents.pluck("studentId")])
  }

  scope :last_7_days, -> {
    UserTodo.where(:createdAt => 7.days.ago.midnight..Time.now)
  }

  scope :last_3_days, -> {
    UserTodo.where(:createdAt => 3.days.ago.midnight..Time.now)
  }

  scope :today, -> {
    UserTodo.where(:createdAt => Date.today.midnight..Time.now)
  }

  scope :tomorrow, -> {
    UserTodo.where(:createdAt => 1.days.ago.midnight..Date.today.midnight)
  }
end
