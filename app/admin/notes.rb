ActiveAdmin.register Note do
  remove_filter :video_annotation, :video, :noteTopics, :topics
  permit_params :name, :content, :description, :externalURL, :epubURL, :epubContent, :createdAt, :updatedAt

  index do
    id_column
    column :name
    column "Content" do |note|
      truncate(note.content, omision: "...", length: 100)
    end
    column :description
    column :externalURL
    column :epubURL
    column "Epub Content" do |note|
      truncate(note.epubContent, omision: "...", length: 100)
    end
    column :createdAt
    column :updatedAt
    actions
  end

  show do
    attributes_table do
      row :id
      row :name do |note|
        raw(note.name)
      end
      row :description do |note|
        raw(note.description)
      end
      row :externalURL do |note|
        raw(note.externalURL)
      end
      row :epubURL do |note|
        raw(note.epubURL)
      end
      row :epubContent do |note|
        truncate(note.epubContent, omision: "...", length: 100)
      end
      row :createdAt do |note|
        note.createdAt
      end
      row :updatedAt do |note|
        note.updatedAt
      end
    end
  end

  form do |f|
    f.inputs "Note" do
      render partial: 'tinymce'
      f.input :name
      f.input :content
      f.input :description
      f.input :externalURL, as: :string
      f.input :epubURL, as: :string
      # f.input :epubContent, hint: link_to('Epub Html', note.githubEpubContent)
    end
    f.actions
  end

end
