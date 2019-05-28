ActiveAdmin.register Post do
  permit_params :url, :title, :description, :section_1

  filter :id_eq, as: :number, label: "Post ID"
  preserve_default_filters!

  index do
    id_column
    column :url
    column :title
    column :description
    actions
  end

  form do |f|
    f.inputs "Post" do
      render partial: 'tinymce'
      f.input :url, as: :string
      f.input :title, as: :string
      f.input :description, as: :string
      f.input :section_1
    end
    f.actions
  end
end
