ActiveAdmin.register FlashCard do

  active_admin_import validate: true,
                      batch_size: 1,
                      timestamps: false,
                      headers_rewrites: { 'title': :title, 'content': :content, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
                      before_batch_import: lambda { |importer|
                                             # add created at and upated at
                                             time = Time.zone.now
                                             importer.csv_lines.each do |line|
                                               importer.options['chapter'] = line[2]
                                               importer.options['time'] = time
                                               line.delete_at(2) # remove chapter name
                                               line.insert(-1, time)
                                               line.insert(-1, time)
                                               p line
                                             end
                                           },
                      after_batch_import: lambda { |importer|
                                            p "after_import"
                                            time = importer.options['time']
                                            chapter_ids = importer.options['chapter'].split("|")

                                            # chapter = Chapter.where(name: chapter_name, subject_id: subject).first

                                            flash_card = FlashCard.where(createdAt: time).first
                                            flash_card_id = flash_card[:id]

                                            chapter_ids.each do |chapter_id|
                                              ChapterFlashCard.create!({
                                                chapterId: chapter_id,
                                                flashCardId: flash_card_id,
                                                createdAt: Time.zone.now,
                                                updatedAt: Time.zone.now,
                                              })
                                            end
                                          },
                      template_object: ActiveAdminImport::Model.new(
                        hint: "File will be imported with such header format: title content topic_id.
        Remove the header from the CSV before uploading.",
                        csv_headers: %w[title content createdAt updatedAt]
                      )


  permit_params :content, :title, :createdAt, :updatedAt, topic_ids: []
  remove_filter :topicFlashCards, :topics

  filter :id_eq, as: :number, label: "Flash Card ID"
  filter :topics, as: :searchable_select, multiple: true, label: "Chapter", :collection => Topic.name_with_subject
  preserve_default_filters!

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Flash Card" do
      render partial: 'tinymce'
      f.input :title, as: :string
      f.input :content

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      render partial: 'hidden_topic_ids', locals: {topics: f.object.topics}
    end
    f.actions
  end
  
end
