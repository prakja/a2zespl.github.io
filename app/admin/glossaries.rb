ActiveAdmin.register Glossary do

  permit_params :word, :translation, :language, :createdAt, :updatedAt, chapter_glossaries_attributes: [:id, :chapterId, :glossaryId, :createdAt, :updatedAt, :_destroy]
  remove_filter :chapter_glossaries

  filter :chapters, as: :searchable_select, multiple: true, label: "Chapter", :collection => Topic.name_with_subject
  preserve_default_filters!


  form do |f|
    f.inputs "Glossary" do
      f.input :word
      f.input :translation
      f.input :language, as: :select, collection: ["hindi"]
    end
    if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
      f.has_many :chapter_glossaries, heading: false, allow_destroy: true do |t|
        t.inputs "Chapter" do
          t.input :chapter, input_html: { class: "select2" }, :collection => Topic.name_with_subject_hinglish
        end
      end
    end
    f.actions
  end
end
