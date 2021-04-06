ActiveAdmin.register Task do
  active_admin_import validate: true,
                      batch_size: 1,
                      timestamps: false,                   
                      headers_rewrites: { 'name': :name, 'topicId': :topicId, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
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
                        hint: "File will be imported with such header format: name, topicId
      Remove the header from the CSV before uploading.",
                        csv_headers: ['name', 'topicId', 'createdAt', 'updatedAt']
                        )
  remove_filter :userTasks, :topic
  permit_params :name, :topic, :topicId, :createdAt, :updatedAt

  form do |f|
    f.inputs "Task" do
      f.input :name, as: :string
      f.input :topic, input_html: { class: "select2" }, :collection => Topic.name_with_subject
    end
    f.actions
  end

  index do
    id_column
    column ("Topic") { |task|
      if not task.topic.nil?
        task.topic.name + " (" + task.topic.subject.name + ")"
      end
    }
    column :name
    actions
  end
end
