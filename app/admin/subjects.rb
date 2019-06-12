ActiveAdmin.register Subject do
  remove_filter :course, :topics
  scope :neetprep_course
end
