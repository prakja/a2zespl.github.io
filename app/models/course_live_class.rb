class CourseLiveClass < ApplicationRecord
  self.table_name = :CourseLiveClass

  belongs_to :course,     class_name: :Course,    foreign_key: :courseId,     optional: true
  belongs_to :live_class, class_name: :LiveClass, foreign_key: :liveClassId,  optional: true
end
