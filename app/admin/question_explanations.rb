ActiveAdmin.register QuestionExplanation do
  remove_filter :question, :course

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:questionId, :courseId],
    headers_rewrites: { 'id': :id, 'questionId': :questionId, 'courseId': :courseId, 'explanation': :explanation},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'questionId', 'explanation', 'courseId', 'id' (optional) in any order."
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
    column ("Explanation") {|qe|
      raw(qe.explanation)
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
    column :explanation
  end

end
