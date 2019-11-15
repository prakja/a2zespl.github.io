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

  form remote: true do |f|
    f.inputs "VideoLink" do
      panel 'Video' do
        if f.object.video.url.include? ".m3u8"
          raw '<script src="https://unpkg.com/video.js/dist/video.js"></script>
          <script src="https://unpkg.com/@videojs/http-streaming/dist/videojs-http-streaming.js"></script>
          <link href="https://unpkg.com/video.js/dist/video-js.css" rel="stylesheet"></link>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/videojs-seek-buttons/dist/videojs-seek-buttons.css"></link>
          <script src="https://cdn.jsdelivr.net/npm/videojs-seek-buttons/dist/videojs-seek-buttons.min.js"></script>
          <div>
            <video id="my_video_1" class="video-js vjs-default-skin" controls preload="auto" width="640" height="268" data-setup=\'{"controls": true}\'>
              <source src="' + f.object.video.url + '" type="application/x-mpegURL">
            </video>
          </div>
          <script>
            player = videojs("my_video_1");
            player.seekButtons({
              forward: 30,
              back: 5
            });
            player.on("timeupdate", function() {$("#video_link_time").val(player.currentTime())});
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
      f.input :name, as: :string
      f.input :videoId, label: "Video", as: :hidden, :input_html => { :value => f.object.videoId }
    end
    f.actions
  end

  controller do
    def new
      params.permit!
      @video_link = VideoLink.new (params[:video_link])
    end

    def create
      create! do |success, failure|
        success.html { redirect_to admin_video_links_url }
        # TODO: link actual object url here
        success.js {flash.now[:notice] = "Video Link created! Id: <a href='/admin/user_links/#{@video_link.id}' target='_blank'>#{@video_link.id}</a>"}
        failure.js {flash.now[:error] = "Video Link NOT created! #{@video_link.errors.full_messages}"}
      end
    end
  end
end
