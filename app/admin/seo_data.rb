ActiveAdmin.register SEOData do
  permit_params :title, :keywords, :description, :paragraph

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "SEOData" do
      render partial: 'tinymce'
      f.input :title
      f.input :description
      f.input :keywords
      f.input :paragraph
    end
    f.actions
  end
end
