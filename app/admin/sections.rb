ActiveAdmin.register Section do
  permit_params :name, :topic, :chapterId, :position, :ncertName, :ncertURL, :ncertSectionLink, contents_attributes: [:id, :title, :contentType, :contentId, :position, :_destroy]
  remove_filter :topic, :contents

  filter :chapterId_eq, as: :searchable_select, collection: -> { Topic.main_course_topic_name_with_subject }, label: "Chapter"

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Section" do
      f.input :name
      f.input :topic, include_hidden: false, input_html: { class: "select2" }, :collection => Topic.main_course_topic_name_with_subject , label: "Chapter"
      f.input :position
      f.input :ncertName
      f.input :ncertURL
      f.input :ncertSectionLink
    end
    f.has_many :contents, new_record: true, allow_destroy: true do |content|
      content.inputs "" do
        content.input :title
        content.input :contentType, :input_html => {value: 'video'}
        content.input :contentId, as: :select, :collection => Topic.get_assets(f.object.chapterId)
        content.input :position
      end
    end
    f.actions
  end
end
