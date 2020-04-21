ActiveAdmin.register SubjectChapter do
  remove_filter :subject, :topic
  permit_params :deleted

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    headers_rewrites: { 'chapterId': :chapterId, 'subjectId': :subjectId, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
    before_batch_import: lambda { |importer|
                           # add created at and upated at
                           time = Time.zone.now
                           importer.csv_lines.each do |line|
                             p line
                             importer.options['time'] = time
                             line.insert(-1, time)
                             line.insert(-1, time)
                           end
                         },
    after_batch_import: lambda { |importer|
                          p "after_import"
                        },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: chapterId', 'subjectId'.
        Remove the header from the CSV before uploading.",
        csv_headers: ['chapterId',	'subjectId', 'createdAt', 'updatedAt']
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
end
