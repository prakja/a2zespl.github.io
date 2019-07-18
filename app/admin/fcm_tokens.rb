ActiveAdmin.register FcmToken do
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

# batch_action :notify do |ids|
#     batch_action_collection.find(ids).each do |post|
#       p post.fcmToken
#     end
#     ActiveAdmin.modal_dialog (
#       "Send email to: "
#     )
#     redirect_to collection_path, alert: "Notification has been sent."
#   end

# active_admin_import validate: false,
#                           template: 'import' ,
#                           template_object: FcmToken.new(
#                               hint: "you can configure CSV options",
#                               csv_options: { col_sep: ";", row_sep: nil, quote_char: nil }
#                           )

batch_action :notify, form: {
  title: :text,
  message: :textarea,
  type: ["", "ExternalWebsite", "InternalWebsite"],
  redirectUrl: :text,
  imageUrl: :text,
  sendToAll: :checkbox
  
} do |ids, inputs|
  fcmTokens = Array.new

  to_send_ids = ids

  if inputs['sendToAll'] == 'on'
    p "Send to all"
    to_send_ids = FcmToken.where(platform: 'android')
    to_send_ids.each do |row|
      fcmTokens << row.fcmToken
    end
  else
    to_send_ids.each do |id|
      fcmTokenRow = FcmToken.find(id)
      fcmTokens << fcmTokenRow.fcmToken
    end
  end

  title = inputs['title']
  message = inputs['message']
  redirect = inputs['redirectUrl']
  type = inputs['type']
  imgUrl = inputs['imageUrl']

  HTTParty.post(
    Rails.configuration.node_site_url + "api/v1/user/sentNotify",
     body: {
      title: title,
      message: message,
      redirectUrl: redirect,
      type: type,
      imgUrl: imgUrl,
      fcmTokens: fcmTokens
  })

  # FcmToken.sent_notification(title, message, redirect, fcmTokens)

  # redirect_to collection_path, notice: [ids, inputs].to_s
end

end
