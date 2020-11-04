class DoubtAnswersController < ApplicationController
  before_action :set_doubt_answer, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  # GET /doubt_answers
  # GET /doubt_answers.json
  def create
  end

  def assign_to_me
    p current_admin_user
    admin_user_id = current_admin_user[:id]
    doubt_admin = DoubtAdmin.new()
    doubt_admin[:doubtId] = params[:doubtId]
    doubt_admin[:admin_user_id] = admin_user_id
    doubt_admin[:created_at] = Time.now
    doubt_admin[:created_at] = Time.now
    doubt_admin.save!
    response = {
      :status => 'ok'
    }
    render json: response, :status => 200
  rescue => exception
    response = {
      :status => 'error',
      :message => exception
    }
    render json: response, :status => 500
  end

  def mark_as_solved
    if not current_admin_user
      raise "User not logged in"
    end

    doubt_id = params[:doubtId]
    doubt = Doubt.find(doubt_id)
    doubt_admin = DoubtAdmin.where(admin_user_id: current_admin_user.id, doubtId: doubt.id)
    if current_admin_user.role != 'admin'
      raise "Not your doubt" if doubt_admin.empty?
    else
      p "Admin user, bypass assign check"
    end
    doubt.doubtSolved = true
    doubt.save

    response = {
      :status => 'ok'
    }
    render json: response, :status => 200
  rescue => exception
    response = {
      :status => 'error',
      :message => exception
    }
    render json: response, :status => 500
  end

  def answer
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @userId = current_admin_user.userId
    @doubt_id = params[:doubt_id]
    if @userId.blank?
      redirect_to "/doubt_answers/connect_user?doubt_id=" + @doubt_id.to_s
    end
    @userEmail = current_admin_user.email
    @doubt = Doubt.find(@doubt_id)
    @doubt_user = User.find(@doubt.userId)
    @doubt_answers = DoubtAnswer.where(doubtId: @doubt_id).order(createdAt: :asc)
    @doubt_answers_data = {}

    @doubt_tag = @doubt.tagType
    # @doubt_data = '<p><a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + @doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + @doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + @doubt.id.to_s) + '">Answer on NEETprep</a></p>'
    @doubt_data = ""

    # @doubt_data += '<img src="' + @doubt.imgUrl + '" style="max-width:640px; max-height:360px;"></img>' if not @doubt.imgUrl.blank?

    if not @doubt.imgUrl.blank?
      @doubt_data +=
      '<div class="canvas-container" style="width: 1000px; height: 500px;">
      <canvas id="c" width="1000" height="500" style="border: 1px solid rgb(204, 204, 204); width: 1000px; height: 500px; left: 0px; top: 0px; touch-action: none; user-select: none;" class="lower-canvas"></canvas>
      <img src="' + @doubt.imgUrl + '" id="my-image" style="max-width:640px; max-height:360px; display: none;"></img>
      </div>
      <script>
        var canvas = new fabric.Canvas("c");
        var imgElement = document.getElementById("my-image");
        var imgInstance = new fabric.Image(imgElement, {
          left: 400,
          top: 400,
          angle: 0
        });
        canvas.add(imgInstance);
        canvas.setZoom(0.1);
        canvas.on("mouse:wheel", function(opt) {
          var minZoom = 0.1;
          var delta = opt.e.deltaY;
          var zoom = canvas.getZoom();
          zoom = zoom + delta/3000;
          if (zoom > 20) zoom = 20;
          if (zoom < minZoom) zoom = minZoom;
          canvas.setZoom(zoom);
          opt.e.preventDefault();
          opt.e.stopPropagation();
        });
      </script>'
    end

    if @doubt_tag == "question"
      @question = Question.find(@doubt.questionId)
      @doubt_data += @question.question
      @doubt_data += '<div style="margin: 16px; padding: 8px; border: 1px solid #828282">' + "Explanation: </br>" + @question.explanation.to_s + '</div>'
      @doubt_data += '<a target="_blank" href="https://www.neetprep.com/question/' + @question.id.to_s + '-abc">View Question on NEETPrep</a>'
      @doubt_data += '<a target="_blank" href="https://admin1.neetprep.com/admin/questions/' + @question.id.to_s + '/edit">Edit Question</a>'
      @doubt_data += '<a target="_blank" href="https://admin1.neetprep.com/questions/add_explanation/' + @question.id.to_s + '">Add Audio Explanation in Question</a>'
    end

    @ism3u8 = "no"
    if @doubt_tag == "video"
      @video = Video.find(@doubt.videoId)
      @annotation = VideoAnnotation.where(annotationId: @doubt.id).first
      timeElapsed = @annotation.videoTimeStampInSeconds
      @seconds = timeElapsed % 60
      @minutes = (timeElapsed / 60) % 60
      @hours = (timeElapsed/3600)

      topic = nil
      if not @doubt.topicId.nil?
        topic = Topic.find(@doubt.topicId)
        subject = Subject.find(topic.subjectId)
      end

      if @video.url.include? ".m3u8"
        @ism3u8 = "yes"
        @doubt_data =+
        '<script src="https://vjs.zencdn.net/7.5.5/video.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/@videojs/http-streaming@1.2.4/dist/videojs-http-streaming.min.js"></script>
        <link href="https://vjs.zencdn.net/7.5.5/video-js.css" rel="stylesheet">
        <div>
          <video-js id="my_video_1" class="vjs-default-skin" controls preload="auto" width="640" height="268">
            <source src="' + @video.url + '" type="application/x-mpegURL">
          </video-js>
        </div>'
      elsif @video.url.include? "youtube"
        uri = URI.parse(@video.url)
        params = CGI.parse(uri.query)
        @doubt_data += '<div><iframe width="640" height="268" src="https://www.youtube.com/embed/' + params['v'].first + '" allowfullscreen> </iframe></div>'
      else
        @urlArray = @video.url.to_s.split('/')
        @vimeoId = @urlArray[-1]
        @doubt_data += '<div><iframe src="https://player.vimeo.com/video/'+@vimeoId+'" width="640" height="320" frameborder="0"  webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></div>'
      end

      if not topic.nil?
        @doubt_data += '<a target="_blank" href="https://www.neetprep.com/video-class/' +
        @video.id.to_s + '-abc?subjectId=' +
        subject.id.to_s + '&chapterId=' +
        topic.id.to_s + '&currentTimeStamp=' +
        timeElapsed.to_s +
        '">Go to Video</a>'
      end

      @doubt_data += '<h5>Time: ' + @hours.to_s.rjust(2, '0') + ':' + @minutes.to_s.rjust(2, '0') + ':' + @seconds.to_s.rjust(2, '0') + '</h5>'
    end

    @doubt_answers.each do |doubt_answer|
      @doubt_answer_user = User.find(doubt_answer.userId)
      @doubt_answers_data[doubt_answer.id] = [@doubt_answer_user.name, doubt_answer.content, Time.parse(doubt_answer.createdAt.to_s), doubt_answer.imgUrl]
    end
  end

  def connect_user
    @userEmail = params[:email]
    @doubtId = params[:doubt_id]
    @userId = current_admin_user.userId
    if @userId.blank?
      @userEmail = current_admin_user.email if @userEmail.blank?
      p "User Id is missing, looking for NEETprep user with email: " + @userEmail
      @neetUser = User.where(email: @userEmail).first
      if @neetUser
        p "NEETprep user found"
        current_admin_user.userId = @neetUser.id
        if current_admin_user.save
          p "Adming user is now connected with NEETprep"
          @userId = current_admin_user.userId
          redirect_to "/doubt_answers/answer?doubt_id=" + @doubtId.to_s
        end
      else
        p "user not found"
      end
    end
  end

  def post_answer
    @doubtId = params[:doubtId]
    @content = params[:content]
    @userId = params[:userId]
    create_answer_row(@userId, @doubtId, @content)
  end

  def toggle_good_flag
    p "Toggle doubt flag"
    @doubtId = params[:doubtId]
    @value = params.require(:value)
    Doubt.where(id: @doubtId).update(goodFlag: @value)
  end

  def create_answer_row (userId, doubtId, content)
    p "Posting Answer, for user " + userId.to_s

    urls = [] 
    content.scan(/(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/) do |match|
      urls << match if not match.nil?
    end

    urls.each do |url|
      to_replace = url[0]
      content = content.gsub(to_replace, '<a target="_blank" href="' + to_replace + '">' + to_replace + '</a>')
    end

    @new_answer = DoubtAnswer.new()
    @new_answer[:content] = content
    @new_answer[:userId] = userId
    @new_answer[:doubtId] = doubtId
    @new_answer[:createdAt] = Time.now
    @new_answer[:updatedAt] = Time. now
    if @new_answer.save
      HTTParty.post(
        Rails.configuration.node_site_url + 'api/v1/webhook/afterCreateDoubtAnswer',
        body: {
          id: doubtId
        }
      )
      redirect_to "/doubt_answers/answer?doubt_id=" + doubtId.to_s
    end
  end

end
