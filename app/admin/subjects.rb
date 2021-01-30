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

  action_item :sync_subject_questions, only: :show, if: proc{ current_admin_user.admin? } do
    link_to 'Sync Subject Questions', '/questions/sync_subject_questions/' + resource.id.to_s, method: :post, data: {confirm: 'Are you sure? This will potentially modify all questions of the subject and even delete unintended questions. Recommended to take a backup of ChapterQuestion before proceeding'}
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course" do
      f.input :course, :include_hidden: false, input_html: {class: "select2"}
      f.input :name
      f.input :description
    end
    f.actions
  end
end
