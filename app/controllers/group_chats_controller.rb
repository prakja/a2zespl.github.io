class GroupChatsController < ApplicationController
  before_action :set_group_chat, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def group
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @group_id = params.require(:id)
    @group = Group.find(@group_id)
    @group_id_encoded = Base64.encode64("Group:" + @group_id.to_s).gsub("\n",'')
    @my_id = current_admin_user.userId
    @livesessionurl = @group.liveSessionUrl
    @messages = Message.where(groupId: 1).limit(40).order('"createdAt" DESC')
  end

  def block_user
    begin
      userId = params.require(:id)
      user = User.find(userID);
      user.blockedUser = true
      user.save
      render :nothing => true, :status => :ok
    rescue => exception
      render :nothing => true, :status => :internal_server_error
    end
  end

  def end_chat
    begin
      groupId = params.require(:id)
      group = User.find(groupId);
      group.expiryAt = Time.now
      group.save
      render :nothing => true, :status => :ok
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
      render :nothing => true, :status => :ok
    rescue => exception
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
