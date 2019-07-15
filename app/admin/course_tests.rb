ActiveAdmin.register CourseTest do
  permit_params :course, :test, :courseId, :testId

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseTest" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :test, input_html: { class: "select" }
    end
    f.actions
  end
end
