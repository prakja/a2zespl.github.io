ActiveAdmin.register Post do
  permit_params :url, :title, :description, :section_1
  form do |f|
    f.inputs "Post" do
      f.input :url, as: :string
      f.input :title, as: :string
      f.input :description, as: :string
      f.input :section_1
    end
    f.actions
  end
end
