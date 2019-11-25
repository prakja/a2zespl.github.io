ActiveAdmin.register Group do
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

index do
  id_column
  column :title
  column :description
  column :startedAt
  column :expiryAt
  column :link do |group|
    link_to  "Live Session", group.liveSessionUrl 
  end
  column :chat do |group|
    link_to  "Open Chat", "/livesession/" + group.id.to_s 
  end
  actions
end

form do |f|
  f.inputs "Groups" do
    f.input :title
    f.input :title
    f.input :startedAt, as: :datetime_picker
    f.input :expiryAt, as: :datetime_picker
    f.input :liveSessionUrl, as: :string
  end
  f.actions
end

end
