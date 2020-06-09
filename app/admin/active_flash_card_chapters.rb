ActiveAdmin.register ActiveFlashCardChapter do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :chapterId
  #
  # or
  #
  # permit_params do
  #   permitted = [:chapterId]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  remove_filter :topic

  form do |f|
    f.inputs "Active Chapter" do
      f.input :topic, input_html: { class: "select2" }, :collection => Topic.name_with_subject
    end
    f.actions
  end
  
end
