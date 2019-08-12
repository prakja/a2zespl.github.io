class Answer < ApplicationRecord
 self.table_name = "Answer"
 belongs_to :user, foreign_key: "userId", class_name: "User"

 scope :paid, ->(paid, start_date, end_date) {
   if paid == "yes"
     where(UserCourse.where('"UserCourse"."userId" = "Answer"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP AND "UserCourse"."createdAt" <= ? and "UserCourse"."createdAt" >= ?', "#{start_date}", "#{end_date}").exists)
   else
     where.not(UserCourse.where('"UserCourse"."userId" = "Answer"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP AND "UserCourse"."createdAt" <= ? and "UserCourse"."createdAt" >= ?', "#{start_date}", "#{end_date}").exists)
   end
 }

 scope :paid_users_answers, -> {paid("yes", Time.now, (Time.now - 30.day))}

end
