ActiveAdmin.register VideoLink do
  permit_params :name, :url, :time, :videoId, :description

  filter :videoId_eq, as: :number, label: "Video ID"
  remove_filter :video
  preserve_default_filters!

  index do
    id_column
    column :name
    column :description
    column :url
    column :time
    column :video
    column :createdAt
    column :updatedAt
    actions
  end

  form remote: true do |f|
    f.inputs "VideoLink" do
      render partial: 'tinymce'
      panel 'Video' do
        if f.object.video.url.include? ".m3u8"
          raw '<script src="https://vjs.zencdn.net/7.5.5/video.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/@videojs/http-streaming@1.2.4/dist/videojs-http-streaming.min.js"></script>
          <link href="https://vjs.zencdn.net/7.5.5/video-js.css" rel="stylesheet"></link>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/videojs-seek-buttons/dist/videojs-seek-buttons.css"></link>
          <script src="https://cdn.jsdelivr.net/npm/videojs-seek-buttons/dist/videojs-seek-buttons.min.js"></script>
          <style>
            .video-js .vjs-current-time, .vjs-no-flex .vjs-current-time {
              display: block !important;
            }
            .vjs-time-divider {
              display: block !important;
            }
            .video-js .vjs-duration, .vjs-no-flex .vjs-duration {
              display: block !important;
            }
          </style>
          <div>
            <video id="my_video_1" class="video-js vjs-default-skin" controls preload="auto" width="640" height="268" data-setup=\'{"controls": true}\'>
              <source src="' + f.object.video.url + '" type="application/x-mpegURL">
            </video>
            </br>
            <button type="button" onclick="updateVideoTime()">Update Time With Video Time</button>
          </div>
          <script>
            function updateVideoTime() {
              $("#video_link_time").val(player.currentTime());
            }
            player = videojs("my_video_1", {
              playbackRates: [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4]
            });
            player.seekButtons({
              forward: 30,
              back: 5
            });
          </script>'
        elsif f.object.video.url.include? "youtube"
          uri = URI.parse(f.object.video.url)
          params = CGI.parse(uri.query)
          raw '
            <div id="player"></div>
            </br>
            <button type="button" onclick="updateVideoTime()">Update Time With Video Time</button>
            <script>
              function updateVideoTime() {
                $("#video_link_time").val(player.getCurrentTime());

              }
              var tag = document.createElement("script");

              tag.src = "https://www.youtube.com/iframe_api";
              var firstScriptTag = document.getElementsByTagName("script")[0];
              firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

              var player;
              function onYouTubeIframeAPIReady() {
                player = new YT.Player("player", {
                  height: "390",
                  width: "640",
                  videoId: "' + params['v'].first  + '"
                });
              }
            </script>
          '
        else
          @urlArray = f.object.video.url.to_s.split('/')
          @vimeoId = @urlArray[-1]
          raw '<script src="https://player.vimeo.com/api/player.js"></script>
          <div>
            <iframe src="https://player.vimeo.com/video/'+@vimeoId+'" width="640" height="320" frameborder="0"  webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
            </br>
            <button type="button" onclick="updateVideoTime()">Update Time With Video Time</button>
          </div>
          <script>
              function updateVideoTime() {
                player.getCurrentTime().then(function(seconds) {
                  $("#video_link_time").val(seconds);
                });
              }
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
      f.input :description
      f.input :videoId, label: "Video", as: :hidden, :input_html => { :value => f.object.videoId }
    end
    f.actions
    panel "Video Links", id: "videoVideoLinks" do
      table_for f.object.video.videoLinks do
        column :name
        column :url
        column :time do |video_link|
          s = video_link.time
          hours = s / (60 * 60)
          s = s - hours * (60*60)
          minutes = s / (60) % 60
          s = s - minutes * (60)
          seconds = s
          raw(hours.to_s.rjust(2, '0') + ":" + minutes.to_s.rjust(2, '0') + ":" + seconds.to_s.rjust(2, '0'))
        end
        column ("View / Edit") {|videoLinks| raw('<a target="_blank" href="/admin/video_links/' + (videoLinks.id).to_s + '">View / Edit</a>')}
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(video: :videoLinks)
    end

    def new
      params.permit!
      @video_link = VideoLink.new (params[:video_link])
    end

    def create
      create! do |success, failure|
        @video_link.video.videoLinks.reload
        success.html { redirect_to admin_video_links_url }
        # TODO: link actual object url here
        success.js {flash.now[:notice] = "Video Link created! Id: <a href='/admin/user_links/#{@video_link.id}' target='_blank'>#{@video_link.id}</a>"}
        failure.js {flash.now[:error] = "Video Link NOT created! #{@video_link.errors.full_messages}"}
      end
    end

    def update
      update! do |success, failure|
        @video_link.video.videoLinks.reload
        success.html { redirect_to admin_video_links_url }
        # TODO: link actual object url here
        success.js {flash.now[:notice] = "Video Link updated! Id: <a href='/admin/user_links/#{@video_link.id}' target='_blank'>#{@video_link.id}</a>"}
        failure.js {flash.now[:error] = "Video Link NOT created! #{@video_link.errors.full_messages}"}
      end
    end
  end
end
