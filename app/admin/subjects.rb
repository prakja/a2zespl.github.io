ActiveAdmin.register Subject do
  permit_params :course, :courseId, :name, :description
  remove_filter :course, :topics, :versions, :subjectTopics
  scope :neetprep_course

  active_admin_import validate: true,
    timestamps: false,
    batch_size: 1,
    headers_rewrites: { 'name': :name, 'description': :description, 'courseId': :courseId, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
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
        hint: "File will be imported with such header format: name', 'description', 'courseId'.
        Remove the header from the CSV before uploading.",
        csv_headers: ['name',	'description', 'courseId', 'createdAt', 'updatedAt']
    )

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
