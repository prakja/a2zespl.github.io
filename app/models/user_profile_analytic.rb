class UserProfileAnalytic < ApplicationRecord
  self.table_name = "UserProfileAnalytic"
  self.primary_key = "id"
  belongs_to :user, class_name: "User", foreign_key: "userId"

  scope :test_count_present, ->(present) {
    if (present == "yes")
      where('"UserProfileAnalytic"."testCount" is not null')
    else
      where('"UserProfileAnalytic"."testCount" is null')
    end
  }

  scope :video_course_students, -> {
     where(UserCourse.where('"UserCourse"."userId" = "UserProfileAnalytic"."userId" AND "expiryAt" >= CURRENT_TIMESTAMP').where(courseId: [8, 141, 18, 19, 20]).exists)
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:test_count_present]
  end

end
