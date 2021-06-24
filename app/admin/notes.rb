ActiveAdmin.register Note do
  remove_filter :video_annotation, :video, :noteTopics, :topics, :versions, :sectionContents
  permit_params :name, :content, :description, :externalURL, :epubURL, :epubContent, :createdAt, :updatedAt
  before_action :create_token, only: [:show]

  controller do
    def create_token
      payload = {
        "type": "Note",
        "id": params[:id]
      }
      @token_lambda = JsonWebToken.encode_for_lambda(payload)
      @url = Rails.application.config.create_image_url
    end
  end

  batch_action :set_image_link, if: proc{ current_admin_user.admin? } do |ids|
    batch_action_collection.find(ids).each do |note|
      note.set_image_link!
    end
    redirect_back fallback_location: collection_path, notice: "The note images have been updated."
  end

  index do
    if current_admin_user.admin?
      selectable_column
    end
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
    column ("History") {|note| raw('<a target="_blank" href="/admin/notes/' + (note.id).to_s + '/history">View History</a>')}
    if current_admin_user.role == 'admin'
      column ("Restore") { |note| raw('<a href="/admin/notes/' + (note.id).to_s + '/restore">Restore</a>')}
    end
      actions
  end

  action_item :set_image_link, only: :show do
    link_to 'Set Image Link', '#', class: 'setImageLink'
  end

  show do
    render partial: 'mathjax'
    render partial: 'notes_show'
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
      row :content do |note|
        raw(note.content)
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

  member_action :history do
    @note = Note.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Note', item_id: @note.id)
    render "layouts/history"
  end

  member_action :restore do
    @note = Note.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Note', item_id: @note.id)
    if !@versions.last.reify.nil?
      @lock_version = @versions.last.reify.lock_version + 1
      @note = @versions.last.reify
      @note.lock_version = @lock_version
      @note.save!
      #@versions.last.destroy
      #@versions.last.destroy
      redirect_back fallback_location: collection_path, notice: "Restored to previos version"
    else
      redirect_back fallback_location: collection_path, notice: "There is no previous version"
    end 
  end
end
