ActiveAdmin.register CourseTest do
  permit_params :course, :test, :courseId, :testId
  remove_filter :course, :test

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:courseId, :testId],
    headers_rewrites: { 'id': :id, 'testId': :testId, 'courseId': :courseId},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'testId', 'courseId', 'id' (optional) in any order."
    )

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseTest" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :test, input_html: { class: "select" }
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:course, :test)
    end
  end

  csv do
    column :id
    column :courseId
    column :testId
  end
end
