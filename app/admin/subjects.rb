ActiveAdmin.register Subject do
  permit_params :course, :courseId, :name, :description
  remove_filter :course, :topics, :versions, :subjectTopics
  scope :neetprep_course

  controller do
    def scoped_collection
      super.includes(:course)
    end
  end

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
