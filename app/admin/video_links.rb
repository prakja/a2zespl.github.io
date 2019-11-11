ActiveAdmin.register VideoLink do
  permit_params :name, :url, :time, :videoId

  filter :videoId_eq, as: :number, label: "Video ID"
  remove_filter :video
  preserve_default_filters!

  index do
    id_column
    column :name
    column :url
    column :time
    column :video
    actions
  end

  form do |f|
    f.inputs "VideoLink" do
      f.input :name, as: :string
      f.input :url, as: :string
      f.input :time
      f.input :videoId
    end
    f.actions
  end
end
