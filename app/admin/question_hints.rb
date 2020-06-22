ActiveAdmin.register QuestionHint do
  remove_filter :question, :course
    permit_params :questionId, :hint, :position, :language, :courseId, :deleted

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:questionId, :courseId],
    headers_rewrites: { 'id': :id, 'questionId': :questionId, 'courseId': :courseId, 'hint': :hint},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'questionId', 'hint', 'courseId', 'id' (optional) in any order."
    )

  index do
    selectable_column
    id_column
    column ("Question") { |qe|
      auto_link(qe.question)
    }
    column ("Course") {|qe|
      auto_link(qe.course)
    }
    column ("Hint") {|qe|
      raw(qe.hint)
    }
  end

  controller do
    def scoped_collection
      super.includes(:question, :course)
    end
  end

  csv do
    column :id
    column :courseId
    column :questionId
    column :hint
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "QuestionHint" do
      render partial: 'tinymce'
      f.input :questionId
      f.input :hint
      f.input :language
      f.input :deleted
      f.input :position
      f.input :courseId
    end
    f.actions
  end

end
