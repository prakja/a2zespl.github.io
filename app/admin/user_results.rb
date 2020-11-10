ActiveAdmin.register UserResult do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :userId, :name, :marks, :air, :state, :city, :year, :userImage, :createdAt, :updatedAt, :year, :userImage
  remove_filter :user
  filter :userId_eq, as: :number, label: "User ID"
  preserve_default_filters!
  #
  # or
  #
  # permit_params do
  #   permitted = [:userId, :name, :marks, :air, :state, :city, :createdAt, :updatedAt, :year, :userImage]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "UserResult" do
      f.input :userId, label: "User Id"
      f.input :name
      f.input :marks
      f.input :air, label: "All India Rank"
      f.input :state
      f.input :city
      f.input :year
      f.input :userImage, label: "User Image"
    end
    f.actions
  end
  
end
