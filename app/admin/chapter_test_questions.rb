ActiveAdmin.register ChapterTestQuestion do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :chapterId, :questionId
  #
  # or
  #
  # permit_params do
  #   permitted = [:chapterId, :questionId]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  scope :botany
  scope :chemistry
  scope :physics
  scope :zoology

  remove_filter :topic, :question

  csv do
    column :questionId
    column :chapterId
  end
  
end
