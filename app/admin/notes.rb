ActiveAdmin.register Note do
  remove_filter :video_annotation, :video
  permit_params :name, :content, :description, :externalURL, :epubURL, :epubContent, :createdAt, :updatedAt

  index do
    id_column
    column :name
    column :content
    column :description
    column :externalURL
    column :epubURL
    column :epubContent
    column :createdAt
    column :updatedAt
    actions
  end

  form do |f|
    f.inputs "Note" do
      render partial: 'tinymce'
      f.input :name
      f.input :content
      f.input :description
      f.input :externalURL, as: :string
      f.input :epubURL, as: :string
      f.input :epubContent, hint: link_to('Epub Html', note.githubEpubContent)
    end
    f.actions
  end

end
