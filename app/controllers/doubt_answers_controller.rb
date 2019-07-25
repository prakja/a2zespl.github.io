class DoubtAnswersController < ApplicationController
  before_action :set_doubt_answer, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  # GET /doubt_answers
  # GET /doubt_answers.json
  def create
  end

  def answer
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
    @doubt_data = '<p><a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + @doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + @doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + @doubt.id.to_s) + '">Answer on NEETprep</a></p>'

    @doubt_data += '<img src="' + @doubt.imgUrl + '" style="max-width:640px; max-height:360px;"></img>' if not @doubt.imgUrl.blank?

    if @doubt_tag == "question"
      @question = Question.find(@doubt.questionId)
      @doubt_data += @question.question
      @doubt_data += '<a target="_blank" href="https://www.neetprep.com/question/' + @question.id.to_s + '-abc">Go to Question</a>'
    end

    if @doubt_tag == "video"
      @video = Video.find(@doubt.videoId)
      @annotation = VideoAnnotation.where(annotationId: @doubt.id).first

      timeElapsed = @annotation.videoTimeStampInSeconds
      @seconds = timeElapsed % 60
      @minutes = (timeElapsed / 60) % 60
      @hours = (timeElapsed/3600)

      @doubt_data += '<a target="_blank" href="https://www.neetprep.com/video-class/' + @video.id.to_s + '-abc&currentTimeStamp=' + timeElapsed.to_s + '">Go to Video</a>'
      
      @doubt_data += '<h5>Time: ' + @hours.to_s + ':' + @minutes.to_s + ':' + @seconds.to_s + '</h5>'
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

  def create_answer_row (userId, doubtId, content)
    p "Posting Answer, for user " + userId.to_s
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
