ActiveAdmin.register Post do
  permit_params :url, :title, :description, :section_1, :useLatestLayout

  filter :id_eq, as: :number, label: "Post ID"
  preserve_default_filters!

  action_item :view, only: :show do
    link_to 'View on site', "https://neetprep.com/exam-info/#{post.url}"
  end

  show do
    attributes_table do
      row :id
      row :url
      row :title
      row :description
      row :useLatestLayout
      row (:section_1) { |post| raw(post.section_1)}
    end
  end

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
      f.input :useLatestLayout, as: :boolean, label: "Use Latest Layout"
      f.input :description, as: :string
      f.input :section_1
    end
    f.actions
  end
end
