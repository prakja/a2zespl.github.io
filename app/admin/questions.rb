ActiveAdmin.register Question do
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
  remove_filter :detail, :topics
  form do |f|
    f.input :question, as: :quill_editor
    f.input :correctOptionIndex
    f.input :explanation, as: :quill_editor
    f.input :testId
    f.input :deleted
    actions
  end
end
