ActiveAdmin.register Motivation do
  permit_params :message, :author

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Delivery" do
      f.input :message, as: :text
      f.input :author
    end
    f.actions
  end
end
