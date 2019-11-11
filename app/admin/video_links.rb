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
    column :createdAt
    column :updatedAt
    actions
  end

  form do |f|
    f.inputs "VideoLink" do
      f.input :video, as: :fake, value: f.object.video.nil? ? 'No Video Selected' : f.object.video.name
      f.input :name, as: :string
      f.input :url, as: :string
      f.input :time, hint: "To be entered in seconds. Ex: 493 would mean 8 minutes 13 seconds"
      f.input :videoId, label: "Video", as: :hidden, :input_html => { :value => f.object.videoId }
    end
    f.actions
  end

  controller do
    def new
      params.permit!
      @video_link = VideoLink.new (params[:video_link])
    end
  end
end
