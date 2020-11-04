ActiveAdmin.register ChapterGlossary do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :chapterId, :glossaryId, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:chapterId, :glossaryId, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
