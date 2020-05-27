ActiveAdmin.register FlashCard do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :content, :title, :createdAt, :updatedAt, topic_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:content, :title, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  remove_filter :topicFlashCards, :topics

  filter :id_eq, as: :number, label: "Flash Card ID"
  filter :topics, as: :searchable_select, multiple: true, label: "Chapter", :collection => Topic.name_with_subject
  preserve_default_filters!

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Flash Card" do
      f.input :title, as: :string
      f.input :content

      f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject
      render partial: 'hidden_topic_ids', locals: {topics: f.object.topics}
    end
    f.actions
  end
  
end
