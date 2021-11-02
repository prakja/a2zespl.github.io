class GroupChatsController < ApplicationController
  before_action :set_group_chat, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def group
    authenticate_admin_user!

    @group_id = params.require(:id)
    @group = Group.find(@group_id)
    @group_id_encoded = Base64.encode64("Group:" + @group_id.to_s).gsub("\n",'')
    @my_id = current_admin_user.userId
    @livesessionurl = @group.liveSessionUrl
    @messages = Message.where(groupId: @group_id).limit(40).order('"createdAt" DESC')
  end

  def teacher_view
    authenticate_admin_user!

    @group_id = params.require(:id)
    @group = Group.find(@group_id)
    @group_id_encoded = Base64.encode64("Group:" + @group_id.to_s).gsub("\n",'')
    @my_id = current_admin_user.userId
    @livesessionurl = @group.liveSessionUrl
    @messages = Message.where(groupId: @group_id).limit(40).order('"createdAt" DESC')
  end

  def block_user
    begin
      userId = params.require(:id)
      user = User.find(userId)
      user.blockedUser = !user.blockedUser
      user.save
      render :status => :ok, :json => {
        id: userId
      }.to_json
    rescue => exception
      p exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def end_chat
    begin
      groupId = params.require(:id)
      group = Group.find(groupId);
      group.expiryAt = Time.now
      group.save
      render :status => :ok, :json => {
        id: groupId
      }.to_json
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def delete_message
    begin
      messageId = params.require(:id)
      message = Message.find(messageId);
      message.deleted = true
      message.save
      render :status => :ok, :json => {
        id: messageId,
        user: message.user.id,
        type: message.type,
      }.to_json
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def check_question
    begin
      id = params.require(:id)
      question = Question.find(id)
      render :status => :ok, :json => {
        question: question.question
      }.to_json
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def send_question
    begin
      msg_type = params.require(:type)
      group_id = params.require(:groupId)
      user_id = params.require(:userId)
      question_id = params.require(:questionId)
      message = Message.create({:questionId => question_id, :type => msg_type, :groupId => group_id, :userId => user_id})
      question = Question.find(question_id)
      render :status => :ok, :json => {
        :content => message.content,
        :id => Base64.encode64("Message:" + message.id.to_s).gsub("\n",''),
        :type => message.type,
        :createdAt => message.createdAt,
        :question => {
          :question => question.question,
          :explanation => question.explanation,
          :correctOptionIndex => question.correctOptionIndex,
          :options => question.options,
          :questionId => question.id,
          :messageId => message.id.to_s,
          :userAnswer => nil
        },
        questionId: question_id,
        :user => {
          :id => Base64.encode64("User:" + message.userId.to_s).gsub("\n",''),
          :profile => {
            :displayName => message.user.user_profile.displayName,
            :id => Base64.encode64("UserProfile:" + message.user.user_profile.id.to_s).gsub("\n",'')
          },
        },
        :userId => message.userId
      }.to_json
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def show_analytics
    group_id = params.require(:groupId)
    results = ActiveRecord::Base.connection.execute("SELECT * ,( CASE WHEN (\"correctAnswerCount\"+\"incorrectAnswerCount\")>1 THEN ((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 END) AS \"correctPercentage\",( CASE  WHEN ((\"correctAnswerCount\"+\"incorrectAnswerCount\")>1) AND (((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 >= 50) THEN 'easy' WHEN ((\"correctAnswerCount\"+\"incorrectAnswerCount\")>1) AND (((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 >= 25) AND (((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 < 50) THEN 'medium' WHEN ((\"correctAnswerCount\"+\"incorrectAnswerCount\")>1) AND (((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 >= 0) AND (((\"correctAnswerCount\"*1.0)/(\"correctAnswerCount\"+\"incorrectAnswerCount\"))*100 < 25) THEN 'difficult' ELSE NULL END ) AS \"difficultyLevel\" FROM ( SELECT \"Question\".\"id\" ,\"Question\".\"correctOptionIndex\" AS \"correctOptionIndex\", \"Question\".\"explanation\" AS \"explanation\", COUNT(CASE WHEN \"Question\".\"correctOptionIndex\" = \"ChatAnswer\".\"userAnswer\" THEN 1 END) AS \"correctAnswerCount\",COUNT(CASE WHEN \"Question\".\"correctOptionIndex\" != \"ChatAnswer\".\"userAnswer\" THEN 1 END) AS \"incorrectAnswerCount\", COUNT(CASE WHEN \"ChatAnswer\".\"userAnswer\" = 0 THEN 1 END) AS \"option1AnswerCount\", COUNT(CASE WHEN \"ChatAnswer\".\"userAnswer\" = 1 THEN 1 END) AS \"option2AnswerCount\", COUNT(CASE WHEN \"ChatAnswer\".\"userAnswer\" = 2 THEN 1 END) AS \"option3AnswerCount\", COUNT(CASE WHEN \"ChatAnswer\".\"userAnswer\" = 3 THEN 1 END) AS \"option4AnswerCount\" FROM \"Question\", \"ChatAnswer\" WHERE \"Question\".\"id\" = \"ChatAnswer\".\"questionId\" AND \"Question\".\"id\" = (SELECT \"questionId\" FROM \"Message\" WHERE \"groupId\" = "+ group_id +" AND \"type\" = 'question' AND \"deleted\" = FALSE AND \"questionId\" IS NOT NULL ORDER BY \"id\" DESC LIMIT 1) GROUP BY \"Question\".\"id\") AS \"TempData\"")
    if results.present?
      render :status => :ok, :json => results.first.to_json
    else
      render :nothing => true, :status => :internal_server_error
    end
  end

  def create_chat
    # if not current_admin_user
    #   redirect_to "/admin/login"
    #   return
    # end

    begin
      content = params.require(:content)
      msg_type = params.require(:type)
      group_id = params.require(:groupId)
      # user_id = current_admin_user.userId
      user_id = params.require(:userId)
      message = Message.create({:content => content, :type => msg_type, :groupId => group_id, :userId => user_id})
      render :status => :ok, :json => {
        :content => message.content,
        :id => Base64.encode64("Message:" + message.id.to_s).gsub("\n",''),
        :type => message.type,
        :createdAt => message.createdAt,
        :user => {
          :id => Base64.encode64("User:" + message.userId.to_s).gsub("\n",''),
          :profile => {
            :displayName => message.user.user_profile.displayName,
            :id => Base64.encode64("UserProfile:" + message.user.user_profile.id.to_s).gsub("\n",'')
          },
        },
        :userId => message.userId
      }.to_json
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end
end
