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
  
end
