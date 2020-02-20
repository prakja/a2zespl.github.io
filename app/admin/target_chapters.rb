ActiveAdmin.register TargetChapter do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :chapterId, :createdAt, :updatedAt, :targetId, :hours, :revision
  #
  # or
  #
  # permit_params do
  #   permitted = [:chapterId, :createdAt, :updatedAt, :targetId, :hours, :revision]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  remove_filter :target, :chapter
  preserve_default_filters!

  filter :targetId_eq, as: :number, label: "Target ID"
  filter :target_userId_eq, as: :number, label: "User ID"

end
