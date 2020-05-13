ActiveAdmin.register Subject do
  permit_params :course, :courseId, :name, :description
  remove_filter :course, :topics, :versions, :subjectTopics
  scope :neetprep_course

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:name, :description, :courseId],
    headers_rewrites: { 'name': :name, 'description': :description, 'courseId': :courseId},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: name', 'description', 'courseId', 'id' (optional) in any order."
    )

  sidebar :related_data, only: :show do
    ul do
      li link_to "Chapters", admin_topics_path(q: {topicSubjects_subjectId_eq: subject.id}, order: 'id_asc')
    end
  end

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
