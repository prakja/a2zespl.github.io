ActiveAdmin.register NcertSentence do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :noteId, :chapterId, :sectionId, :sentence, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:noteId, :chapterId, :sectionId, :sentence, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter :note, :chapter, :section

  filter :chapterId_eq, as: :searchable_select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :noteId_eq
  filter :sectionId_eq
  preserve_default_filters!
  
end
