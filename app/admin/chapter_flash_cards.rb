ActiveAdmin.register ChapterFlashCard do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :chapterId, :createdAt, :updatedAt, :flashCardId
  #
  # or
  #
  # permit_params do
  #   permitted = [:chapterId, :createdAt, :updatedAt, :flashCardId]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter :topic, :flash_card
  
end
