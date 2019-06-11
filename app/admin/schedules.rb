ActiveAdmin.register Schedule do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  remove_filter :scheduleItems
  permit_params :createdAt, :updatedAt, :name

  form do |f|
    f.inputs "Schedule" do
      f.input :name, as: :string
    end
    f.actions
  end

end
