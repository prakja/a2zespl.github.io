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
      panel 'Video' do
        raw '<script src="https://unpkg.com/video.js/dist/video.js"></script>
        <script src="https://unpkg.com/@videojs/http-streaming/dist/videojs-http-streaming.js"></script>
        <link href="https://unpkg.com/video.js/dist/video-js.css" rel="stylesheet">
        <div>
          <video-js id="my_video_1" class="vjs-default-skin" controls preload="auto" width="640" height="268">
            <source src="' + f.object.video.url + '" type="application/x-mpegURL">
          </video-js>
        </div>
        <script>
          player = videojs("my_video_1");
          player.on("pause", function() {$("#video_link_time").val(player.currentTime())});
        </script>'
      end
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
