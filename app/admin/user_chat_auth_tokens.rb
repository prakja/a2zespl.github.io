require 'csv'

ActiveAdmin.register UserChatAuthToken do
  preserve_default_filters!

  remove_filter :user
  filter :userId_eq, as: :number, label: "User Id"
  permit_params :userId, :authToken, :createdAt, :updatedAt, :defaultGroupId

  action_item only: :index do
    link_to 'Upload User List', action: :upload_user_csv
  end

  collection_action :upload_user_csv do
    render 'user_list_upload'
  end

  collection_action :create_auth_tokens, method: :post do
    file_path = params[:user_list].tempfile.path
    csv_file_data = CSV.read(file_path)

    user_email_arr = csv_file_data
      .reduce([]) { |acc, rec| acc << rec.first}
      .filter { |rec| not rec.nil?}
      .map(&:to_s)

    user_id_arr = User.where(email: user_email_arr).pluck(:id).uniq

    # filter out user id that do not already exists
    existing_user_id = UserChatAuthToken.where(userId: user_id_arr).pluck(:userId)
    new_user_id_arr = user_id_arr.filter { |id| not existing_user_id.include?(id)}

    user_chat_tokens = new_user_id_arr.map { |user_id| UserChatAuthToken.new(:userId => user_id, :authToken => '')}
    user_chat_token_ids = user_chat_tokens
      .each { |token| token.save!(validate: false)}
      .map(&:id)

    domain = (Rails.env === "production") ? 'https://www.neetprep.com' : 'http://local.neetprep.com'

    res = HTTParty.post("#{domain}/register-cometchat", body: {user_chat_auth_token_id: user_chat_token_ids})

    if res.code.to_i != 200
      flash[:danger] = "Encountered an error while creating tokens for users"
      UserChatAuthToken.where(id: user_chat_token_ids).delete_all
    else
      flash[:notice] = "User Chat Tokens will be created shortly, refresh in case not created"
    end

    redirect_to action: :index
  end

  index do
    id_column
    column :user
    column :authToken
    column :defaultGroupId
    column :createdAt
    column :updatedAt
    actions
  end

  form do |f|
    f.inputs "User Chat Auth Token" do
      f.input :userId, :label => 'User ID', input_html: {required: true, disabled: (not f.object.new_record?)}
      f.input :authToken, :label => 'Auth Token', input_html: {required: true}, :include_blank => false
      f.input :defaultGroupId, :label => 'Default Group ID'
    end
    f.actions
  end

end
