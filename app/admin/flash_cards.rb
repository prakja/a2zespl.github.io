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


  permit_params :content, :title, :createdAt, :updatedAt, topicFlashCards_attributes: [:id, :seqId, :chapterId, :_destroy]
  # , topic_ids: []
  remove_filter :topicFlashCards, :userFlashCards, :users, :versions

  filter :id_eq, as: :number, label: "Flash Card ID"
  filter :topics, as: :searchable_select, multiple: true, label: "Chapter", :collection => Topic.name_with_subject
  preserve_default_filters!

  show do |f|
    render partial: 'mathjax'
    attributes_table do
      row :id
      row (:title) {|flash_card| raw(flash_card.title)}
      row (:answer) {|flash_card| raw(flash_card.content)}
      row (:seqId) {|flash_card| flash_card&.topicFlashCards&.first&.seqId}
      row (:chapter) {|flash_card| flash_card&.topicFlashCards&.first&.topic}
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Flash Card" do
      render partial: 'tinymce'
      f.input :title
      f.input :content

      # render partial: 'hidden_topic_ids', locals: {topics: f.object.topics}
    end

    f.has_many :topicFlashCards, heading: false, allow_destroy: true do |t|
      t.inputs "Chapter" do
        t.input :seqId
        t.input :topic, input_html: { class: "select2" }, :collection => Topic.name_with_subject_hinglish
      end
    end
    f.actions
  end

  member_action :history do
    @flashCard = FlashCard.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'FlashCard', item_id: @flashCard.id)
    render "layouts/history"
  end

  index do
    render partial: 'img_css'
    id_column
    column (:title) {|flash_card| raw(flash_card.title)}
    column (:answer) {|flash_card| raw(flash_card.content)}
    column (:seqId) {|flash_card| flash_card&.topicFlashCards&.first&.seqId}
    column ("History") {|flash_card| raw('<a target="_blank" href="/admin/flash_cards/' + (flash_card.id).to_s + '/history">View History</a>')}
    actions
  end

end
