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
        if f.object.video.url.include? ".m3u8"
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
        elsif f.object.video.url.include? "youtube"
          uri = URI.parse(f.object.video.url)
          params = CGI.parse(uri.query)
          raw '
            <div id="player"></div>
            <script>
            var tag = document.createElement("script");

            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName("script")[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
              player = new YT.Player("player", {
                height: "390",
                width: "640",
                videoId: "' + params['v'].first  + '",
                events: {
                  "onStateChange": onPlayerStateChange
                }
              });
            }

            function onPlayerStateChange(event) {
              if (event.data == YT.PlayerState.PAUSED) {
                $("#video_link_time").val(player.getCurrentTime());
              }
            }
          </script>
          '
        else
          @urlArray = f.object.video.url.to_s.split('/')
          @vimeoId = @urlArray[-1]
          raw '<script src="https://player.vimeo.com/api/player.js"></script>
          <div>
            <iframe src="https://player.vimeo.com/video/'+@vimeoId+'" width="640" height="320" frameborder="0"  webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
          </div>
          <script>
              var iframe = document.querySelector("iframe");
              var player = new Vimeo.Player(iframe);

              player.on("pause", function() {
                player.getCurrentTime().then(function(seconds) {
                  $("#video_link_time").val(seconds);
                });
              });
          </script>
          '
        end
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
