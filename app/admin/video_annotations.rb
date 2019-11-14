ActiveAdmin.register VideoAnnotation do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

permit_params :annotationType, :videoId, :annotationId, :videoTimeStampInSeconds, note_attributes: [:content]

remove_filter :note, :video

form do |f|
  f.inputs "Annotation" do
    f.input :video, as: :fake, value: f.object.video.nil? ? 'No Video Selected' : f.object.video.name
    f.inputs "Note", for: [:note, f.object.note || Note.new] do |n|
      render partial: 'tinymce'
      n.input :content
    end
      # f.inputs :for => [
      #   :note,
      #   f.object.note || Note.new
      #   ] do |n_f|
      #     n_f.input :content
      # end
      f.input :annotationType, label: "Annotation type", as: :hidden, :input_html => { :value => 'Note' }
      f.input :videoId, label: "Video", as: :hidden, :input_html => { :value => f.object.videoId }
      f.input :videoTimeStampInSeconds, hint: "To be entered in seconds. Ex: 493 would mean 8 minutes 13 seconds", label: "Show At"
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
            player.on("pause", function() {$("#video_annotation_videoTimeStampInSeconds").val(player.currentTime())});
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
                $("#video_annotation_videoTimeStampInSeconds").val(player.getCurrentTime());
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
                  $("#video_annotation_videoTimeStampInSeconds").val(seconds);
                });
              });
          </script>
          '
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row ("Content") {raw(resource.note.try(:content))}
      row :video
      row :videoTimeMS
    end
  end

  controller do
    def new
      params.permit!
      @video_annotation = VideoAnnotation.new (params[:video_annotation])
      @video_annotation.build_note
    end
  end

end
