ActiveAdmin.register ChapterVideo do 
  remove_filter :topic, :video

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    on_duplicate_key_update: [:videoId, :chapterId],
    headers_rewrites: { 'id': :id, 'chapterId': :chapterId, 'videoId': :videoId},
    before_batch_import: lambda { |importer|
                          p "before_import"
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'chapterId', 'videoId', 'id' (optional) in any order."
    )

  index do
    selectable_column
    id_column
    column ("Video") { |cv|
      auto_link(cv.video)
    }
    column ("Chapter") {|cv|
      auto_link(cv.topic)
    }
  end

  controller do
    def scoped_collection
      super.includes(:video, :topic)
    end
  end

  csv do
    column :id
    column :videoId
    column :chapterId
  end

end
