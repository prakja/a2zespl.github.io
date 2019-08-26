ActiveAdmin.register Subject do
  permit_params :course, :courseId, :name, :description
  remove_filter :course, :topics, :versions
  scope :neetprep_course

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course" do
      f.input :course
      f.input :name
      f.input :description
    end
    f.actions
  end
end
