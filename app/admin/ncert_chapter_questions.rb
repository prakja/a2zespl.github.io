ActiveAdmin.register NcertChapterQuestion do
  remove_filter :ncertQuestion, :chapter

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1000,
    on_duplicate_key_update: [:questionId, :chapterId],
    headers_rewrites: { 'id': :id, 'chapterId': :chapterId, 'questionId': :questionId},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'chapterId', 'questionId', 'id' (optional) in any order."
    )

  index do
    selectable_column
    id_column
    column ("Question") { |cv|
      auto_link(cv.ncertQuestion)
    }
    column ("Chapter") {|cv|
      auto_link(cv.chapter)
    }
  end

  controller do
    def scoped_collection
      super.includes(:ncertQuestion, :chapter)
    end
  end

  csv do
    column :id
    column :questionId
    column :chapterId
  end

end

