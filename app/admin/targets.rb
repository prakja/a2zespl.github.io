ActiveAdmin.register Target do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks
  #
  # or
  #
  # permit_params do
  #   permitted = [:createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  remove_filter :target_chapters, :user, :test
  preserve_default_filters!

  filter :userId_eq, as: :number, label: "User ID"
end
