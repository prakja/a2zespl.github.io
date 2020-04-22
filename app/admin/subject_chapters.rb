ActiveAdmin.register SubjectChapter do
  remove_filter :subject, :topic
  permit_params :deleted

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:subjectId, :chapterId],
    headers_rewrites: { 'id': :id, 'chapterId': :chapterId, 'subjectId': :subjectId},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'chapterId', 'subjectId', 'id' (optional) in any order."
    )

  index do
    selectable_column
    id_column
    column ("Subject") { |sc|
      auto_link(sc.subject)
    }
    column ("Chapter") {|sc|
      auto_link(sc.topic)
    }
    toggle_bool_column :deleted
  end
  controller do
    def scoped_collection
      super.includes(:subject, :topic)
    end
  end

  csv do
    column :id
    column :subjectId
    column :chapterId
  end

end
