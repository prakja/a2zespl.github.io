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

batch_action :notify, form: {
  title: :text,
  message: :textarea,
  redirectUrl: :text
  
} do |ids, inputs|
  fcmTokens = Array.new

  ids.each do |id|
    fcmTokenRow = FcmToken.find(id)
    fcmTokens << fcmTokenRow.fcmToken
  end
  title = inputs['title']
  message = inputs['message']
  redirect = inputs['redirectUrl']


  HTTParty.post(
    "http://localhost:3000/api/v1/user/sentNotify",
     body: {
      title: title,
      message: message,
      redirectUrl: redirect,
      fcmTokens: fcmTokens
  })

  # FcmToken.sent_notification(title, message, redirect, fcmTokens)

  # redirect_to collection_path, notice: [ids, inputs].to_s
end

end
