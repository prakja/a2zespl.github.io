class DoubtAnswersController < ApplicationController
  before_action :set_doubt_answer, only: [:show, :edit, :update, :destroy]

  # GET /doubt_answers
  # GET /doubt_answers.json
  def answer
    @userId = current_admin_user.userId
    @doubt_id = params[:doubt_id]
    @doubt = Doubt.find(@doubt_id)
    @doubt_user = User.find(@doubt.userId)
    @doubt_answers = DoubtAnswer.where(doubtId: @doubt_id)
    @doubt_answers_data = {}

    @doubt_tag = @doubt.tagType
    @doubt_data = '<p><a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + @doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + @doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + @doubt.id.to_s) + '">Answer on NEETprep</a></p>'

    @doubt_data += '<img src="' + @doubt.imgUrl + '" width="800" height="600">' if not @doubt.imgUrl.blank?

    if @doubt_tag == "question"
      @question = Question.find(@doubt.questionId)
      @doubt_data += @question.question
      @doubt_data += '<a target="_blank" href="https://www.neetprep.com/question/' + @question.id.to_s + '-abc">Go to Question</a>'
    end

    if @doubt_tag == "video"
      @video = Video.find(@doubt.videoId)
      @doubt_data += '<a target="_blank" href="https://www.neetprep.com/video-class/' + @video.id.to_s + '-abc">Go to Video</a>'
    end

    @doubt_answers.each do |doubt_answer|
      @doubt_answer_user = User.find(doubt_answer.userId)
      @doubt_answers_data[doubt_answer.id] = [@doubt_answer_user.name, doubt_answer.content]
    end
  end

  def post_answer
    @doubt_id = params[:doubtId]
    @content = params[:content]
    @userId = current_admin_user.userId
    @new_answer = DoubtAnswer.new()
    @new_answer[:content] = @content
    @new_answer[:userId] = @userId
    @new_answer[:doubtId] = @doubt_id
    @new_answer[:createdAt] = Time.now
    @new_answer[:updatedAt] = Time. now
    if @new_answer.save
      HTTParty.post(
        Rails.configuration.node_site_url + 'api/v1/webhook/afterCreateDoubtAnswer',
        body: {
          id: @doubt_id
        }
      )
      redirect_to "/doubt_answers/answer?doubt_id=" + @doubt_id.to_s 
    end 
  end

  end
