ActiveAdmin.register ScheduleItem do
  config.create_another = true
  scope :boost_up_today
  active_admin_import validate: true,
                      batch_size: 1,
                      timestamps: false,
                      # rubocop:disable Metrics/LineLength
                      headers_rewrites: { 'name': :name, 'description': :description, 'scheduleId': :scheduleId, 'topicId': :topicId, 'hours': :hours, 'link': :link, 'scheduledAt': :scheduledAt, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
                      # csv_options: { col_sep: ",", row_sep: :auto, quote_char: '"', field_size_limit: nil, converters: nil, unconverted_fields: nil, headers: false, return_headers: false, header_converters: nil, skip_blanks: false, force_quotes: false, skip_lines: nil, liberal_parsing: false, },
                      # rubocop:enable Metrics/LineLength
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
                        hint: "File will be imported with such header format: name, description, scheduleId, topicId, hours, link, scheduledAt.
      Remove the header from the CSV before uploading.",
                        csv_headers: ['name', 'description', 'scheduleId',  'topicId', 'hours', 'link', 'scheduledAt', 'createdAt', 'updatedAt']
                        # csv_options: { col_sep: ",", row_sep: :auto, quote_char: '"', field_size_limit: nil, converters: nil, unconverted_fields: nil, headers: false, return_headers: false, header_converters: nil, skip_blanks: false, force_quotes: false, skip_lines: nil, liberal_parsing: false, }
                        # rubocop:enable Metrics/LineLength
                      )
remove_filter :scheduleItemUsers, :topic, :scheduleItemAssets
permit_params :name, :schedule, :scheduleId, :topic, :topicId, :hours, :link, :scheduledAt, :createdAt, :updatedAt, :description

form do |f|
  f.inputs "Schedule Item" do
    render partial: 'tinymce'
    f.input :name, as: :string
    f.input :description
    f.input :schedule, input_html: { class: "select2" }, :collection => Schedule.active
    f.input :topic, label: "Chapter", input_html: { class: "select2" }, :collection => Topic.name_with_subject
    # f.input :topicId
    f.input :hours
    f.input :link, as: :string
    f.input :scheduledAt, label: "Scheduled At", as: :datetime_picker
  end
  f.actions
end

index do
  id_column
  column :scheduledAt
  column ("Topic") { |scheduleItem|
    if not scheduleItem.topic.nil?
      scheduleItem.topic.name + " (" + scheduleItem.topic.subject.name + ")"
    end
  }
  column :name
  column :hours
  column (:link) { |schedule_item|
    raw('<a target="_blank" href="' + schedule_item.link + '">' + schedule_item.link + '</a>') if not schedule_item.link.blank?
  }
  column :schedule
  column (:description) { |schedule_item| raw(schedule_item.description)  }
  actions
end

action_item :show_assets, only: :show do
  link_to 'Asset List', '/admin/schedule_item_assets?q[ScheduleItem_id_eq]=' + resource.id.to_s
end

action_item :add_asset, only: :show do
  link_to 'Add Assets', '/admin/schedule_item_assets/new?schedule_item_asset[ScheduleItem_id]=' + resource.id.to_s
end

end
